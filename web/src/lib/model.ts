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
  active?: boolean;
  createdAt?: FsDate;
};

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
