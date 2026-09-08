"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  collection,
  deleteDoc,
  doc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import {
  CONTRACT_STATUSES,
  contractStatusLabel,
  fetchClients,
  fetchContracts,
  formatDate,
  fromDateInput,
  toDateInput,
  type Client,
  type Contract,
  type ContractStatus,
} from "@/lib/model";
import { EditIcon, TrashIcon } from "@/components/icons";

type FormState = {
  id: string | null; // null = novo
  name: string;
  clientId: string;
  status: ContractStatus;
  description: string;
  startDate: string;
  endDate: string;
};

const EMPTY_FORM: FormState = {
  id: null,
  name: "",
  clientId: "",
  status: "active",
  description: "",
  startDate: "",
  endDate: "",
};

export default function ContractsPage() {
  const { profile } = useAuth();
  const companyId = profile?.companyId ?? null;

  const [clients, setClients] = useState<Client[]>([]);
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [confirmDelete, setConfirmDelete] = useState<Contract | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const clientNames = useMemo(() => {
    const m = new Map<string, string>();
    clients.forEach((c) => m.set(c.id, c.name));
    return m;
  }, [clients]);

  const load = useCallback(async () => {
    if (!companyId) {
      setContracts([]);
      setClients([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [cs, ct] = await Promise.all([
        fetchClients(companyId),
        fetchContracts(companyId),
      ]);
      setClients(cs);
      setContracts(ct);
    } catch {
      setLoadError("Não foi possível carregar os contratos.");
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  function openNew() {
    setFormError(null);
    setForm({ ...EMPTY_FORM, clientId: clients[0]?.id ?? "" });
  }

  function openEdit(c: Contract) {
    setFormError(null);
    setForm({
      id: c.id,
      name: c.name ?? "",
      clientId: c.clientId ?? "",
      status: (c.status as ContractStatus) ?? "active",
      description: c.description ?? "",
      startDate: toDateInput(c.startDate),
      endDate: toDateInput(c.endDate),
    });
  }

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!form || !companyId) return;
    if (!form.name.trim() || !form.clientId) {
      setFormError("Nome e cliente são obrigatórios.");
      return;
    }
    setFormError(null);
    setSaving(true);
    const start = fromDateInput(form.startDate);
    const end = fromDateInput(form.endDate);
    if (start && end && end < start) {
      setFormError("A data final não pode ser anterior à inicial.");
      setSaving(false);
      return;
    }
    try {
      const base = {
        clientId: form.clientId,
        name: form.name.trim(),
        description: form.description.trim() || null,
        status: form.status,
        startDate: start ? Timestamp.fromDate(start) : null,
        endDate: end ? Timestamp.fromDate(end) : null,
        updatedAt: serverTimestamp(),
      };
      if (form.id) {
        await updateDoc(doc(db, "contracts", form.id), base);
      } else {
        const ref = doc(collection(db, "contracts"));
        await setDoc(ref, {
          ...base,
          companyId,
          createdAt: serverTimestamp(),
        });
      }
      setForm(null);
      await load();
    } catch {
      setFormError("Falha ao salvar o contrato. Verifique suas permissões.");
    } finally {
      setSaving(false);
    }
  }

  async function onDelete(c: Contract) {
    setActionError(null);
    setDeleting(true);
    try {
      await deleteDoc(doc(db, "contracts", c.id));
      setConfirmDelete(null);
      await load();
    } catch {
      setActionError("Falha ao excluir o contrato.");
    } finally {
      setDeleting(false);
    }
  }

  const period = (c: Contract) => {
    const s = formatDate(c.startDate);
    const e = formatDate(c.endDate);
    if (s === "—" && e === "—") return "—";
    return `${s} → ${e}`;
  };

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Contratos</h1>
          <p className="mt-1 text-sm text-slate-500">
            Contratos da empresa por cliente.
          </p>
        </div>
        {companyId && (
          <button
            onClick={openNew}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
          >
            Novo contrato
          </button>
        )}
      </div>

      {!companyId && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Sua conta não está vinculada a uma empresa.
        </p>
      )}

      {companyId && !loading && clients.length === 0 && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Nenhum cliente cadastrado ainda. Cadastre um cliente antes de criar um
          contrato.
        </p>
      )}

      <div className="mt-8">
        {loading ? (
          <p className="text-sm text-slate-500">Carregando…</p>
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : contracts.length === 0 ? (
          <p className="rounded-lg border border-dashed border-slate-200 p-6 text-center text-sm text-slate-500">
            Nenhum contrato cadastrado ainda.
          </p>
        ) : (
          <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-5 py-3 font-medium">Contrato</th>
                  <th className="px-5 py-3 font-medium">Cliente</th>
                  <th className="px-5 py-3 font-medium">Status</th>
                  <th className="hidden px-5 py-3 font-medium md:table-cell">
                    Período
                  </th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {contracts.map((c) => (
                  <tr key={c.id}>
                    <td className="px-5 py-3 font-medium">{c.name}</td>
                    <td className="px-5 py-3 text-slate-600">
                      {clientNames.get(c.clientId) ?? "—"}
                    </td>
                    <td className="px-5 py-3">
                      <StatusBadge status={c.status} />
                    </td>
                    <td className="hidden px-5 py-3 text-slate-500 md:table-cell">
                      {period(c)}
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex justify-end gap-2">
                        <button
                          onClick={() => openEdit(c)}
                          title="Editar"
                          aria-label="Editar"
                          className="rounded-lg border border-slate-300 p-2 text-slate-600 hover:bg-slate-50 hover:text-brand"
                        >
                          <EditIcon />
                        </button>
                        <button
                          onClick={() => {
                            setActionError(null);
                            setConfirmDelete(c);
                          }}
                          title="Excluir"
                          aria-label="Excluir"
                          className="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50"
                        >
                          <TrashIcon />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Form de contrato (novo/editar) */}
      {form && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !saving && setForm(null)}
        >
          <form
            onSubmit={onSave}
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-lg"
          >
            <h2 className="text-lg font-semibold">
              {form.id ? "Editar contrato" : "Novo contrato"}
            </h2>

            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <label className="block text-sm font-medium text-slate-700 sm:col-span-2">
                Nome
                <input
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-slate-700">
                Cliente
                <select
                  required
                  value={form.clientId}
                  onChange={(e) => setForm({ ...form, clientId: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  <option value="" disabled>
                    Selecione…
                  </option>
                  {clients.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </label>

              <label className="block text-sm font-medium text-slate-700">
                Status
                <select
                  value={form.status}
                  onChange={(e) =>
                    setForm({ ...form, status: e.target.value as ContractStatus })
                  }
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  {CONTRACT_STATUSES.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </label>

              <label className="block text-sm font-medium text-slate-700">
                Início (opcional)
                <input
                  type="date"
                  value={form.startDate}
                  onChange={(e) =>
                    setForm({ ...form, startDate: e.target.value })
                  }
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-slate-700">
                Fim (opcional)
                <input
                  type="date"
                  value={form.endDate}
                  onChange={(e) => setForm({ ...form, endDate: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-slate-700 sm:col-span-2">
                Descrição (opcional)
                <textarea
                  rows={3}
                  value={form.description}
                  onChange={(e) =>
                    setForm({ ...form, description: e.target.value })
                  }
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>
            </div>

            {formError && <p className="mt-3 text-sm text-red-600">{formError}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setForm(null)}
                disabled={saving}
                className="rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium hover:bg-slate-50 disabled:opacity-60"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={saving || clients.length === 0}
                className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark disabled:opacity-60"
              >
                {saving ? "Salvando…" : "Salvar"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Confirmar exclusão */}
      {confirmDelete && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !deleting && setConfirmDelete(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">Excluir contrato</h2>
            <p className="mt-2 text-sm text-slate-600">
              Excluir <span className="font-medium">{confirmDelete.name}</span>?
              Esta ação não pode ser desfeita.
            </p>
            {actionError && (
              <p className="mt-3 text-sm text-red-600">{actionError}</p>
            )}
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmDelete(null)}
                disabled={deleting}
                className="rounded-lg border border-slate-300 px-4 py-1.5 text-sm font-medium hover:bg-slate-50 disabled:opacity-60"
              >
                Cancelar
              </button>
              <button
                onClick={() => onDelete(confirmDelete)}
                disabled={deleting}
                className="rounded-lg bg-red-600 px-4 py-1.5 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-60"
              >
                {deleting ? "Excluindo…" : "Excluir"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function StatusBadge({ status }: { status?: string }) {
  const styles: Record<string, string> = {
    active: "bg-green-100 text-green-700",
    inactive: "bg-slate-100 text-slate-600",
    expired: "bg-amber-100 text-amber-700",
  };
  return (
    <span
      className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${
        styles[status ?? ""] ?? "bg-slate-100 text-slate-600"
      }`}
    >
      {contractStatusLabel(status)}
    </span>
  );
}
