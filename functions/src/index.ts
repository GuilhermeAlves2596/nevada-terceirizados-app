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
