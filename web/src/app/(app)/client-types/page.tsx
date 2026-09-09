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
import { fetchClients, fetchClientTypes, type Client, type ClientType } from "@/lib/model";
import { Loader } from "@/components/spinner";
import { EditIcon, TrashIcon } from "@/components/icons";

type FormState = { id: string | null; name: string; active: boolean };

const EMPTY_FORM: FormState = { id: null, name: "", active: true };

export default function ClientTypesPage() {
  const { profile } = useAuth();
  const companyId = profile?.companyId ?? null;

  const [types, setTypes] = useState<ClientType[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [confirmDelete, setConfirmDelete] = useState<ClientType | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const usageByType = useMemo(() => {
    const m = new Map<string, number>();
    clients.forEach((c) => {
      if (c.clientTypeId) m.set(c.clientTypeId, (m.get(c.clientTypeId) ?? 0) + 1);
    });
    return m;
  }, [clients]);

  const load = useCallback(async () => {
    if (!companyId) {
      setTypes([]);
      setClients([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [t, c] = await Promise.all([
        fetchClientTypes(companyId),
        fetchClients(companyId),
      ]);
      setTypes(t);
      setClients(c);
    } catch {
      setLoadError("Não foi possível carregar os tipos de cliente.");
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  function openNew() {
    setFormError(null);
    setForm({ ...EMPTY_FORM });
  }

  function openEdit(t: ClientType) {
    setFormError(null);
    setForm({ id: t.id, name: t.name ?? "", active: t.active !== false });
  }

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!form || !companyId) return;
    if (!form.name.trim()) {
      setFormError("O nome é obrigatório.");
      return;
    }
    setFormError(null);
    setSaving(true);
    try {
      const base = {
        name: form.name.trim(),
        active: form.active,
        updatedAt: serverTimestamp(),
      };
      if (form.id) {
        await updateDoc(doc(db, "clientTypes", form.id), base);
      } else {
        const ref = doc(collection(db, "clientTypes"));
        await setDoc(ref, { ...base, companyId, createdAt: serverTimestamp() });
      }
      setForm(null);
      await load();
    } catch {
      setFormError("Falha ao salvar. Verifique suas permissões.");
    } finally {
      setSaving(false);
    }
  }

  async function onDelete(t: ClientType) {
    setActionError(null);
    setDeleting(true);
    try {
      await deleteDoc(doc(db, "clientTypes", t.id));
      setConfirmDelete(null);
      await load();
    } catch {
      setActionError("Falha ao excluir o tipo.");
    } finally {
      setDeleting(false);
    }
  }

  const linkedClients = confirmDelete
    ? usageByType.get(confirmDelete.id) ?? 0
    : 0;

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Tipos de cliente</h1>
          <p className="mt-1 text-sm text-muted">
            Categorias usadas para agrupar clientes e vincular checklists padrão.
          </p>
        </div>
        {companyId && (
          <button
            onClick={openNew}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
          >
            Novo tipo
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
        ) : types.length === 0 ? (
          <p className="rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
            Nenhum tipo cadastrado ainda.
          </p>
        ) : (
          <ul className="divide-y divide-border overflow-hidden rounded-2xl border border-border bg-surface">
            {types.map((t) => (
              <li key={t.id} className="flex items-center justify-between px-5 py-4">
                <div>
                  <p className="font-medium">{t.name}</p>
                  <p className="text-sm text-muted">
                    {(usageByType.get(t.id) ?? 0)} cliente(s)
                    {t.active === false ? " · inativo" : ""}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openEdit(t)}
                    title="Editar"
                    aria-label="Editar"
                    className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
                  >
                    <EditIcon />
                  </button>
                  <button
                    onClick={() => {
                      setActionError(null);
                      setConfirmDelete(t);
                    }}
                    title="Excluir"
                    aria-label="Excluir"
                    className="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50"
                  >
                    <TrashIcon />
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Form */}
      {form && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !saving && setForm(null)}
        >
          <form
            onSubmit={onSave}
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md rounded-2xl bg-surface p-6 shadow-lg"
          >
            <h2 className="text-lg font-semibold">
              {form.id ? "Editar tipo" : "Novo tipo"}
            </h2>
            <label className="mt-4 block text-sm font-medium">
              Nome
              <input
                required
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
              />
            </label>
            <label className="mt-4 flex items-center gap-2 text-sm font-medium">
              <input
                type="checkbox"
                checked={form.active}
                onChange={(e) => setForm({ ...form, active: e.target.checked })}
                className="h-4 w-4 rounded border-border text-brand focus:ring-brand"
              />
              Ativo
            </label>
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
            <h2 className="text-lg font-semibold">Excluir tipo</h2>
            {linkedClients > 0 ? (
              <p className="mt-2 text-sm text-muted">
                <span className="font-medium">{confirmDelete.name}</span> está em{" "}
                {linkedClients} cliente(s). Troque o tipo desses clientes antes de
                excluir.
              </p>
            ) : (
              <p className="mt-2 text-sm text-muted">
                Excluir <span className="font-medium">{confirmDelete.name}</span>?
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
                disabled={deleting || linkedClients > 0}
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
