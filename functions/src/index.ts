import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

initializeApp();
setGlobalOptions({region: "southamerica-east1"});

const db = getFirestore();
const auth = getAuth();

/** Gera uma senha temporária legível (8 chars, sem ambíguos). */
function generateTempPassword(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
  let out = "";
  for (let i = 0; i < 8; i++) {
    out += chars[Math.floor(Math.random() * chars.length)];
  }
  return out;
}

/**
 * Redefine a senha de um funcionário e devolve a nova senha temporária.
 *
 * Só o cliente não pode redefinir a senha de outro usuário, então isso vive no
 * Admin SDK. Autorização: quem chama precisa ser supervisor/companyAdmin/
 * platformAdmin da MESMA empresa; supervisor só pode redefinir funcionário de
 * um contrato do seu escopo.
 */
export const resetEmployeePassword = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Faça login novamente.");
  }

  const employeeId = request.data?.employeeId as string | undefined;
  if (!employeeId) {
    throw new HttpsError("invalid-argument", "employeeId é obrigatório.");
  }

  const callerSnap = await db.doc(`users/${callerUid}`).get();
  const caller = callerSnap.data();
  if (!caller) {
    throw new HttpsError("permission-denied", "Perfil não encontrado.");
  }
  const callerRole = caller.role as string;
  if (!["supervisor", "companyAdmin", "platformAdmin"].includes(callerRole)) {
    throw new HttpsError("permission-denied", "Sem permissão para redefinir senha.");
  }

  const empSnap = await db.doc(`users/${employeeId}`).get();
  const emp = empSnap.data();
  if (!emp) {
    throw new HttpsError("not-found", "Funcionário não encontrado.");
  }
  if (emp.role !== "employee") {
    throw new HttpsError(
      "failed-precondition",
      "Só é possível redefinir a senha de um funcionário.",
    );
  }

  // Isolamento por empresa (platformAdmin ignora).
  if (callerRole !== "platformAdmin" && emp.companyId !== caller.companyId) {
    throw new HttpsError("permission-denied", "Funcionário de outra empresa.");
  }

  // Supervisor: só funcionário de um contrato do seu escopo.
  if (callerRole === "supervisor") {
    const callerContracts: string[] =
      Array.isArray(caller.contractIds) ? caller.contractIds : [];
    const empContracts: string[] =
      Array.isArray(emp.contractIds) ? emp.contractIds : [];
    const inScope = empContracts.some((c) => callerContracts.includes(c));
    if (!inScope) {
      throw new HttpsError("permission-denied", "Funcionário fora do seu escopo.");
    }
  }

  const tempPassword = generateTempPassword();
  await auth.updateUser(employeeId, {password: tempPassword});
  await db.doc(`users/${employeeId}`).update({
    mustChangePassword: true,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {temporaryPassword: tempPassword};
});

/**
 * Cria a conta de acesso (Firebase Auth) + o perfil `/users` de um funcionário,
 * server-side (substitui o workaround client-side de instância secundária).
 * Login por CPF (e-mail sintético). Autorização: supervisor/companyAdmin/
 * platformAdmin da mesma empresa; supervisor só no seu escopo de contrato.
 */
export const createEmployee = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Faça login novamente.");
  }
  const d = request.data ?? {};
  const contractId = d.contractId as string | undefined;
  const clientId = d.clientId as string | undefined;
  const name = (d.name as string | undefined)?.trim();
  const rawCpf = d.cpf as string | undefined;
  if (!contractId || !clientId || !name || !rawCpf) {
    throw new HttpsError("invalid-argument", "Dados obrigatórios ausentes.");
  }
  const cpf = rawCpf.replace(/\D/g, "");
  if (cpf.length !== 11) {
    throw new HttpsError("invalid-argument", "CPF inválido (11 dígitos).");
  }

  const caller = (await db.doc(`users/${callerUid}`).get()).data();
  if (!caller) {
    throw new HttpsError("permission-denied", "Perfil não encontrado.");
  }
  const callerRole = caller.role as string;
  if (!["supervisor", "companyAdmin", "platformAdmin"].includes(callerRole)) {
    throw new HttpsError("permission-denied", "Sem permissão para cadastrar.");
  }
  if (callerRole === "supervisor") {
    const callerContracts: string[] =
      Array.isArray(caller.contractIds) ? caller.contractIds : [];
    if (!callerContracts.includes(contractId)) {
      throw new HttpsError("permission-denied", "Contrato fora do seu escopo.");
    }
  }

  const contract = (await db.doc(`contracts/${contractId}`).get()).data();
  if (!contract) {
    throw new HttpsError("not-found", "Contrato não encontrado.");
  }
  const companyId = callerRole === "platformAdmin" ?
    (contract.companyId as string) :
    (caller.companyId as string);
  if (contract.companyId !== companyId) {
    throw new HttpsError("permission-denied", "Contrato de outra empresa.");
  }
  if (contract.clientId !== clientId) {
    throw new HttpsError("invalid-argument", "Cliente não corresponde ao contrato.");
  }

  const dup = await db.collection("users")
    .where("companyId", "==", companyId)
    .where("cpf", "==", cpf)
    .limit(1)
    .get();
  if (!dup.empty) {
    throw new HttpsError("already-exists", "Já existe um funcionário com este CPF.");
  }

  const syntheticEmail = `${cpf}@func.nevada.app`;
  const tempPassword = generateTempPassword();
  let uid: string;
  try {
    const rec = await auth.createUser({email: syntheticEmail, password: tempPassword});
    uid = rec.uid;
  } catch (e) {
    const code = (e as {code?: string}).code;
    if (code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "Já existe um funcionário com este CPF.");
    }
    throw new HttpsError("internal", "Não foi possível criar o acesso.");
  }

  const email = (d.email as string | undefined)?.trim();
  const phone = (d.phone as string | undefined)?.trim();
  const jobTitle = (d.jobTitle as string | undefined)?.trim();
  const now = FieldValue.serverTimestamp();
  await db.doc(`users/${uid}`).set({
    name,
    role: "employee",
    companyId,
    contractIds: [contractId],
    clientIds: [clientId],
    cpf,
    email: email && email.length ? email : null,
    phone: phone && phone.length ? phone : null,
    jobTitle: jobTitle && jobTitle.length ? jobTitle : null,
    mustChangePassword: true,
    active: true,
    createdAt: now,
    updatedAt: now,
  });

  return {uid, temporaryPassword: tempPassword};
});

/**
 * Exclui a conta de acesso (Auth) + o perfil `/users` de um usuário.
 * Autorização: platformAdmin/companyAdmin da empresa; supervisor só funcionário
 * do seu escopo. Não permite excluir a si mesmo nem um platformAdmin.
 */
export const deleteUserAccount = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Faça login novamente.");
  }
  const userId = request.data?.userId as string | undefined;
  if (!userId) {
    throw new HttpsError("invalid-argument", "userId é obrigatório.");
  }
  if (userId === callerUid) {
    throw new HttpsError("failed-precondition", "Você não pode excluir a si mesmo.");
  }

  const caller = (await db.doc(`users/${callerUid}`).get()).data();
  if (!caller) {
    throw new HttpsError("permission-denied", "Perfil não encontrado.");
  }
  const callerRole = caller.role as string;
  const target = (await db.doc(`users/${userId}`).get()).data();
  if (!target) {
    throw new HttpsError("not-found", "Usuário não encontrado.");
  }
  if (target.role === "platformAdmin") {
    throw new HttpsError("permission-denied", "Não é possível excluir esse usuário.");
  }

  const sameCompany = callerRole === "platformAdmin" ||
    target.companyId === caller.companyId;
  if (!sameCompany) {
    throw new HttpsError("permission-denied", "Usuário de outra empresa.");
  }

  if (callerRole === "supervisor") {
    if (target.role !== "employee") {
      throw new HttpsError("permission-denied", "Sem permissão.");
    }
    const callerContracts: string[] =
      Array.isArray(caller.contractIds) ? caller.contractIds : [];
    const targetContracts: string[] =
      Array.isArray(target.contractIds) ? target.contractIds : [];
    if (!targetContracts.some((c) => callerContracts.includes(c))) {
      throw new HttpsError("permission-denied", "Funcionário fora do seu escopo.");
    }
  } else if (!["companyAdmin", "platformAdmin"].includes(callerRole)) {
    throw new HttpsError("permission-denied", "Sem permissão.");
  }

  try {
    await auth.deleteUser(userId);
  } catch (e) {
    const code = (e as {code?: string}).code;
    if (code !== "auth/user-not-found") {
      throw new HttpsError("internal", "Falha ao remover o acesso.");
    }
  }
  await db.doc(`users/${userId}`).delete();
  return {ok: true};
});
