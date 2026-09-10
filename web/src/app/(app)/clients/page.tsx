"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  collection,
  deleteDoc,
  doc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { Loader } from "@/components/spinner";
import {
  fetchClients,
  fetchClientTypes,
  fetchContracts,
  type Client,
  type ClientType,
  type Contract,
} from "@/lib/model";
import { EditIcon, TrashIcon } from "@/components/icons";

type FormState = {
  id: string | null; // null = novo
  name: string;
  document: string;
  phone: string;
  email: string;
  address: string;
  clientTypeId: string;
  active: boolean;
};

const EMPTY_FORM: FormState = {
  id: null,
  name: "",
  document: "",
  phone: "",
  email: "",
  address: "",
  clientTypeId: "",
  active: true,
};

export default function ClientsPage() {
  const { profile } = useAuth();
  const companyId = profile?.companyId ?? null;

  const [clients, setClients] = useState<Client[]>([]);
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [types, setTypes] = useState<ClientType[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [confirmDelete, setConfirmDelete] = useState<Client | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const contractCountByClient = useMemo(() => {
    const m = new Map<string, number>();
    contracts.forEach((c) => m.set(c.clientId, (m.get(c.clientId) ?? 0) + 1));
    return m;
  }, [contracts]);

  const typeNames = useMemo(() => {
    const m = new Map<string, string>();
    types.forEach((t) => m.set(t.id, t.name));
    return m;
  }, [types]);

  const load = useCallback(async () => {
    if (!companyId) {
      setClients([]);
      setContracts([]);
      setTypes([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [cl, ct] = await Promise.all([
        fetchClients(companyId),
        fetchContracts(companyId),
      ]);
      setClients(cl);
      setContracts(ct);
    } catch {
      setLoadError("Não foi possível carregar os clientes.");
    } finally {
      setLoading(false);
    }
    // Tipos numa chamada à parte: se falhar (ex.: rules ainda não deployadas),
    // a lista de clientes continua funcionando — só o dropdown de tipo fica vazio.
    try {
      setTypes(await fetchClientTypes(companyId));
    } catch {
      setTypes([]);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  function openNew() {
    setFormError(null);
    setForm({ ...EMPTY_FORM });
  }

  function openEdit(c: Client) {
    setFormError(null);
    setForm({
      id: c.id,
      name: c.name ?? "",
      document: c.document ?? "",
      phone: c.phone ?? "",
      email: c.email ?? "",
      address: c.address ?? "",
      clientTypeId: c.clientTypeId ?? "",
      active: c.active !== false,
    });
  }

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!form || !companyId) return;
    if (
      !form.name.trim() ||
      !form.document.trim() ||
      !form.phone.trim() ||
      !form.email.trim() ||
      !form.address.trim() ||
      !form.clientTypeId
    ) {
      setFormError("Preencha todos os campos.");
      return;
    }
    setFormError(null);
    setSaving(true);
    try {
      const base = {
        name: form.name.trim(),
        document: form.document.trim() || null,
        phone: form.phone.trim() || null,
        email: form.email.trim() || null,
        address: form.address.trim() || null,
        clientTypeId: form.clientTypeId || null,
        active: form.active,
        updatedAt: serverTimestamp(),
      };
      if (form.id) {
        await updateDoc(doc(db, "clients", form.id), base);
      } else {
        const ref = doc(collection(db, "clients"));
        await setDoc(ref, {
          ...base,
          companyId,
          createdAt: serverTimestamp(),
        });
      }
      setForm(null);
      await load();
    } catch {
      setFormError("Falha ao salvar o cliente. Verifique suas permissões.");
    } finally {
      setSaving(false);
    }
  }

  async function onDelete(c: Client) {
    setActionError(null);
    setDeleting(true);
    try {
      await deleteDoc(doc(db, "clients", c.id));
      setConfirmDelete(null);
      await load();
    } catch {
      setActionError("Falha ao excluir o cliente.");
    } finally {
      setDeleting(false);
    }
  }

  const linkedContracts = confirmDelete
    ? contractCountByClient.get(confirmDelete.id) ?? 0
    : 0;

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Clientes</h1>
          <p className="mt-1 text-sm text-muted">
            Clientes atendidos pela empresa.
          </p>
        </div>
        {companyId && (
          <button
            onClick={openNew}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
          >
            Novo cliente
          </button>
        )}
      </div>

      {!companyId && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Sua conta não está vinculada a uma empresa.
        </p>
      )}

      <div className="mt-8">
        {loading ? (
          <Loader />
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : clients.length === 0 ? (
          <p className="rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
            Nenhum cliente cadastrado ainda.
          </p>
        ) : (
          <div className="overflow-hidden rounded-2xl border border-border bg-surface">
            <table className="w-full text-sm">
              <thead className="bg-surface-2 text-left text-xs uppercase tracking-wide text-muted">
                <tr>
                  <th className="px-5 py-3 font-medium">Cliente</th>
                  <th className="hidden px-5 py-3 font-medium lg:table-cell">
                    Tipo
                  </th>
                  <th className="hidden px-5 py-3 font-medium sm:table-cell">
                    Documento
                  </th>
                  <th className="hidden px-5 py-3 font-medium md:table-cell">
                    Telefone
                  </th>
                  <th className="px-5 py-3 font-medium">Contratos</th>
                  <th className="px-5 py-3 font-medium">Status</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {clients.map((c) => (
                  <tr key={c.id}>
                    <td className="px-5 py-3 font-medium">{c.name}</td>
                    <td className="hidden px-5 py-3 text-muted lg:table-cell">
                      {c.clientTypeId
                        ? (typeNames.get(c.clientTypeId) ?? "—")
                        : "—"}
                    </td>
                    <td className="hidden px-5 py-3 text-muted sm:table-cell">
                      {c.document || "—"}
                    </td>
                    <td className="hidden px-5 py-3 text-muted md:table-cell">
                      {c.phone || "—"}
                    </td>
                    <td className="px-5 py-3 text-muted">
                      {contractCountByClient.get(c.id) ?? 0}
                    </td>
                    <td className="px-5 py-3">
                      <span
                        className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${
                          c.active === false
                            ? "bg-surface-2 text-muted"
                            : "bg-green-100 text-green-700"
                        }`}
                      >
                        {c.active === false ? "Inativo" : "Ativo"}
                      </span>
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex justify-end gap-2">
                        <button
                          onClick={() => openEdit(c)}
                          title="Editar"
                          aria-label="Editar"
                          className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
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

      {/* Form de cliente (novo/editar) */}
      {form && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !saving && setForm(null)}
        >
          <form
            onSubmit={onSave}
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-lg rounded-2xl bg-surface p-6 shadow-lg"
          >
            <h2 className="text-lg font-semibold">
              {form.id ? "Editar cliente" : "Novo cliente"}
            </h2>

            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <label className="block text-sm font-medium text-fg sm:col-span-2">
                Nome
                <input
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-fg">
                CNPJ/CPF
                <input
                  required
                  value={form.document}
                  onChange={(e) =>
                    setForm({ ...form, document: e.target.value })
                  }
                  className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-fg">
                Telefone
                <input
                  required
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-fg">
                E-mail
                <input
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-fg">
                Endereço
                <input
                  required
                  value={form.address}
                  onChange={(e) => setForm({ ...form, address: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-border px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>

              <label className="block text-sm font-medium text-fg sm:col-span-2">
                Tipo de cliente
                <select
                  required
                  value={form.clientTypeId}
                  onChange={(e) =>
                    setForm({ ...form, clientTypeId: e.target.value })
                  }
                  className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  <option value="" disabled>
                    Selecione…
                  </option>
                  {types
                    .filter(
                      (t) => t.active !== false || t.id === form.clientTypeId,
                    )
                    .map((t) => (
                      <option key={t.id} value={t.id}>
                        {t.name}
                      </option>
                    ))}
                </select>
                {types.length === 0 && (
                  <span className="mt-1 block text-xs text-amber-700">
                    Cadastre um tipo em “Tipos de cliente” primeiro.
                  </span>
                )}
              </label>

              <label className="flex items-center gap-2 text-sm font-medium text-fg sm:col-span-2">
                <input
                  type="checkbox"
                  checked={form.active}
                  onChange={(e) => setForm({ ...form, active: e.target.checked })}
                  className="h-4 w-4 rounded border-border text-brand focus:ring-brand"
                />
                Ativo
              </label>
            </div>

            {formError && <p className="mt-3 text-sm text-red-600">{formError}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setForm(null)}
                disabled={saving}
                className="rounded-lg border border-border px-4 py-2 text-sm font-medium hover:bg-surface-2 disabled:opacity-60"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={saving}
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
            className="w-full max-w-md rounded-2xl bg-surface p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-semibold">Excluir cliente</h2>
            {linkedContracts > 0 ? (
              <p className="mt-2 text-sm text-muted">
                <span className="font-medium">{confirmDelete.name}</span> tem{" "}
                {linkedContracts} contrato(s) vinculado(s). Exclua ou reatribua
                esses contratos antes de remover o cliente.
              </p>
            ) : (
              <p className="mt-2 text-sm text-muted">
                Excluir <span className="font-medium">{confirmDelete.name}</span>?
                Esta ação não pode ser desfeita.
              </p>
            )}
            {actionError && (
              <p className="mt-3 text-sm text-red-600">{actionError}</p>
            )}
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmDelete(null)}
                disabled={deleting}
                className="rounded-lg border border-border px-4 py-1.5 text-sm font-medium hover:bg-surface-2 disabled:opacity-60"
              >
                Cancelar
              </button>
              <button
                onClick={() => onDelete(confirmDelete)}
                disabled={deleting || linkedContracts > 0}
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
