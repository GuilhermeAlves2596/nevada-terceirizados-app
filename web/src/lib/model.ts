import {
  collection,
  getDocs,
  query,
  where,
  type Timestamp,
} from "firebase/firestore";
import { db } from "./firebase";

/** Timestamp do Firestore (ou algo com toDate) — para datas lidas. */
export type FsDate = Timestamp | { toDate?: () => Date } | null | undefined;

export function formatDate(ts?: FsDate): string {
  const d = ts && "toDate" in ts && typeof ts.toDate === "function"
    ? ts.toDate()
    : null;
  if (!d) return "—";
  try {
    return d.toLocaleDateString("pt-BR");
  } catch {
    return "—";
  }
}

/** "YYYY-MM-DD" (para <input type="date">) a partir de um Timestamp. */
export function toDateInput(ts?: FsDate): string {
  const d = ts && "toDate" in ts && typeof ts.toDate === "function"
    ? ts.toDate()
    : null;
  if (!d) return "";
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${mm}-${dd}`;
}

/** Date a partir de "YYYY-MM-DD" ao meio-dia local (evita virar o dia por fuso). */
export function fromDateInput(value: string): Date | null {
  if (!value) return null;
  const d = new Date(`${value}T12:00:00`);
  return isNaN(d.getTime()) ? null : d;
}

export type ContractStatus = "active" | "inactive" | "expired";

export const CONTRACT_STATUSES: { value: ContractStatus; label: string }[] = [
  { value: "active", label: "Ativo" },
  { value: "inactive", label: "Inativo" },
  { value: "expired", label: "Expirado" },
];

export function contractStatusLabel(value?: string): string {
  return CONTRACT_STATUSES.find((s) => s.value === value)?.label ?? "—";
}

export type Client = {
  id: string;
  name: string;
  document?: string | null;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  clientTypeId?: string | null;
  active?: boolean;
  createdAt?: FsDate;
};

export type ClientType = {
  id: string;
  name: string;
  active?: boolean;
};

// ---------- Checklists padrão ----------

export type ServiceType =
  | "limpeza"
  | "jardinagem"
  | "portaria"
  | "recepcao"
  | "higienizacao"
  | "apoioAdministrativo"
  | "movimentacaoCarga";

export const SERVICE_TYPES: { value: ServiceType; label: string }[] = [
  { value: "limpeza", label: "Limpeza" },
  { value: "jardinagem", label: "Jardinagem" },
  { value: "portaria", label: "Portaria" },
  { value: "recepcao", label: "Recepção" },
  { value: "higienizacao", label: "Higienização" },
  { value: "apoioAdministrativo", label: "Apoio Administrativo" },
  { value: "movimentacaoCarga", label: "Movimentação de Carga" },
];

export function serviceTypeLabel(value?: string): string {
  return SERVICE_TYPES.find((s) => s.value === value)?.label ?? "—";
}

export type ChecklistItemLite = {
  id: string;
  description: string;
  order: number;
  required: boolean;
};

export type StandardChecklist = {
  id: string;
  name: string;
  serviceType: string;
  clientTypeId?: string | null;
  items: ChecklistItemLite[];
  active?: boolean;
};

/** Checklists PADRÃO da empresa (isStandard=true). */
export async function fetchStandardChecklists(
  companyId: string,
): Promise<StandardChecklist[]> {
  const snap = await getDocs(
    query(
      collection(db, "checklists"),
      where("companyId", "==", companyId),
      where("isStandard", "==", true),
    ),
  );
  return snap.docs
    .map((d) => {
      const x = d.data();
      const items = Array.isArray(x.items)
        ? (x.items as Record<string, unknown>[])
            .map((it) => ({
              id: (it.id as string) ?? "",
              description: (it.description as string) ?? "",
              order: (it.order as number | undefined) ?? 0,
              required: (it.required as boolean | undefined) ?? true,
            }))
            .sort((a, b) => a.order - b.order)
        : [];
      return {
        id: d.id,
        name: (x.name as string) ?? "",
        serviceType: (x.serviceType as string) ?? "limpeza",
        clientTypeId: (x.clientTypeId as string | null | undefined) ?? null,
        items,
        active: (x.active as boolean | undefined) ?? true,
      };
    })
    .sort((a, b) => a.name.localeCompare(b.name));
}

/** Tipos de cliente da empresa (ordenados por nome). */
export async function fetchClientTypes(companyId: string): Promise<ClientType[]> {
  const snap = await getDocs(
    query(collection(db, "clientTypes"), where("companyId", "==", companyId)),
  );
  return snap.docs
    .map((d) => ({ id: d.id, ...(d.data() as Omit<ClientType, "id">) }))
    .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
}

export type Contract = {
  id: string;
  clientId: string;
  name: string;
  description?: string | null;
  status: ContractStatus;
  startDate?: FsDate;
  endDate?: FsDate;
};

/** Clientes da empresa (ordenados por nome). */
export async function fetchClients(companyId: string): Promise<Client[]> {
  const snap = await getDocs(
    query(collection(db, "clients"), where("companyId", "==", companyId)),
  );
  return snap.docs
    .map((d) => ({ id: d.id, ...(d.data() as Omit<Client, "id">) }))
    .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
}

/** Contratos da empresa (ordenados por nome). */
export async function fetchContracts(companyId: string): Promise<Contract[]> {
  const snap = await getDocs(
    query(collection(db, "contracts"), where("companyId", "==", companyId)),
  );
  return snap.docs
    .map((d) => ({ id: d.id, ...(d.data() as Omit<Contract, "id">) }))
    .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
}

// ---------- Relatórios ----------

export type NamedLite = { id: string; name: string };
export type UserLite = {
  id: string;
  name?: string;
  role?: string;
  email?: string | null;
};

export type ExecPhoto = {
  id?: string;
  downloadUrl?: string | null;
  storagePath?: string | null;
  createdAt?: FsDate;
};

export type ExecItem = {
  id?: string;
  description: string;
  order: number;
  required: boolean;
  completed: boolean;
  completedAt?: FsDate;
};

export type TaskExecutionLite = {
  id: string;
  taskId: string;
  employeeId: string;
  status: string;
  startedAt?: FsDate;
  finishedAt?: FsDate;
  observation?: string | null;
  items: ExecItem[];
  photos: ExecPhoto[];
};

export type TaskLite = {
  id: string;
  contractId: string;
  clientId: string;
  locationId: string;
  checklistId: string;
  assignedTo: string;
};

async function fetchNamed(
  coll: string,
  companyId: string,
): Promise<NamedLite[]> {
  const snap = await getDocs(
    query(collection(db, coll), where("companyId", "==", companyId)),
  );
  return snap.docs.map((d) => ({
    id: d.id,
    name: (d.data().name as string | undefined) ?? "",
  }));
}

export const fetchChecklists = (companyId: string) =>
  fetchNamed("checklists", companyId);
export const fetchLocations = (companyId: string) =>
  fetchNamed("locations", companyId);

/** Usuários da empresa (para nome do funcionário e filtro). */
export async function fetchUsers(companyId: string): Promise<UserLite[]> {
  const snap = await getDocs(
    query(collection(db, "users"), where("companyId", "==", companyId)),
  );
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<UserLite, "id">) }));
}

/** Tarefas da empresa. */
export async function fetchTasks(companyId: string): Promise<TaskLite[]> {
  const snap = await getDocs(
    query(collection(db, "tasks"), where("companyId", "==", companyId)),
  );
  return snap.docs.map((d) => {
    const x = d.data();
    return {
      id: d.id,
      contractId: (x.contractId as string) ?? "",
      clientId: (x.clientId as string) ?? "",
      locationId: (x.locationId as string) ?? "",
      checklistId: (x.checklistId as string) ?? "",
      assignedTo: (x.assignedTo as string) ?? "",
    };
  });
}

/**
 * Execuções CONCLUÍDAS da empresa. Query por companyId + status (2 igualdades,
 * sem índice composto); o recorte por período/contrato/funcionário é feito no
 * cliente sobre esse conjunto.
 */
export async function fetchCompletedExecutions(
  companyId: string,
): Promise<TaskExecutionLite[]> {
  const snap = await getDocs(
    query(
      collection(db, "taskExecutions"),
      where("companyId", "==", companyId),
      where("status", "==", "completed"),
    ),
  );
  return snap.docs.map((d) => {
    const x = d.data();
    const photos = Array.isArray(x.photos)
      ? (x.photos as Record<string, unknown>[]).map((p) => ({
          id: p.id as string | undefined,
          downloadUrl: (p.downloadUrl as string | null | undefined) ?? null,
          storagePath: (p.storagePath as string | null | undefined) ?? null,
          createdAt: p.createdAt as FsDate,
        }))
      : [];
    const items = Array.isArray(x.items)
      ? (x.items as Record<string, unknown>[])
          .map((it) => ({
            id: it.id as string | undefined,
            description: (it.description as string | undefined) ?? "",
            order: (it.order as number | undefined) ?? 0,
            required: (it.required as boolean | undefined) ?? true,
            completed: (it.completed as boolean | undefined) ?? false,
            completedAt: it.completedAt as FsDate,
          }))
          .sort((a, b) => a.order - b.order)
      : [];
    return {
      id: d.id,
      taskId: (x.taskId as string) ?? "",
      employeeId: (x.employeeId as string) ?? "",
      status: (x.status as string) ?? "",
      startedAt: x.startedAt as FsDate,
      finishedAt: x.finishedAt as FsDate,
      observation: (x.observation as string | null | undefined) ?? null,
      items,
      photos,
    };
  });
}

/** Date de um FsDate (ou null). */
export function tsToDate(ts?: FsDate): Date | null {
  return ts && "toDate" in ts && typeof ts.toDate === "function"
    ? ts.toDate()
    : null;
}
