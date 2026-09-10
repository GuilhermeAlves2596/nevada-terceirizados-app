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
import { useToast } from "@/lib/toast";
import { errorMessage } from "@/lib/errors";
import {
  fetchClientTypes,
  fetchStandardChecklists,
  serviceTypeLabel,
  SERVICE_TYPES,
  type ClientType,
  type ServiceType,
  type StandardChecklist,
} from "@/lib/model";
import { Loader } from "@/components/spinner";
import { EditIcon, TrashIcon } from "@/components/icons";

type ItemForm = { id: string; description: string; required: boolean };

type FormState = {
  id: string | null;
  name: string;
  serviceType: ServiceType;
  clientTypeId: string;
  items: ItemForm[];
};

function newId(): string {
  try {
    return crypto.randomUUID();
  } catch {
    return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  }
}

const EMPTY_FORM = (): FormState => ({
  id: null,
  name: "",
  serviceType: "limpeza",
  clientTypeId: "",
  items: [{ id: newId(), description: "", required: true }],
});

export default function StandardChecklistsPage() {
  const { profile, subscriptionActive } = useAuth();
  const companyId = profile?.companyId ?? null;
  const toast = useToast();
  const subInactive = subscriptionActive === false;

  const [lists, setLists] = useState<StandardChecklist[]>([]);
  const [types, setTypes] = useState<ClientType[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [confirmDelete, setConfirmDelete] = useState<StandardChecklist | null>(null);
  const [deleting, setDeleting] = useState(false);

  const typeNames = useMemo(() => {
    const m = new Map<string, string>();
    types.forEach((t) => m.set(t.id, t.name));
    return m;
  }, [types]);

  const load = useCallback(async () => {
    if (!companyId) {
      setLists([]);
      setTypes([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [cl, tp] = await Promise.all([
        fetchStandardChecklists(companyId),
        fetchClientTypes(companyId),
      ]);
      setLists(cl);
      setTypes(tp);
    } catch {
      setLoadError("Não foi possível carregar os checklists padrão.");
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  function openNew() {
    setFormError(null);
    setForm({ ...EMPTY_FORM(), clientTypeId: types[0]?.id ?? "" });
  }

  function openEdit(c: StandardChecklist) {
    setFormError(null);
    setForm({
      id: c.id,
      name: c.name,
      serviceType: (c.serviceType as ServiceType) ?? "limpeza",
      clientTypeId: c.clientTypeId ?? "",
      items: c.items.length
        ? c.items.map((it) => ({
            id: it.id || newId(),
            description: it.description,
            required: it.required,
          }))
        : [{ id: newId(), description: "", required: true }],
    });
  }

  function patchItem(i: number, patch: Partial<ItemForm>) {
    if (!form) return;
    const items = form.items.slice();
    items[i] = { ...items[i], ...patch };
    setForm({ ...form, items });
  }

  function moveItem(i: number, dir: -1 | 1) {
    if (!form) return;
    const j = i + dir;
    if (j < 0 || j >= form.items.length) return;
    const items = form.items.slice();
    [items[i], items[j]] = [items[j], items[i]];
    setForm({ ...form, items });
  }

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!form || !companyId) return;
    const items = form.items
      .map((it) => ({ ...it, description: it.description.trim() }))
      .filter((it) => it.description.length > 0);
    if (!form.name.trim() || !form.clientTypeId || items.length === 0) {
      setFormError("Informe nome, tipo de cliente e ao menos um item.");
      return;
    }
    setFormError(null);
    setSaving(true);
    try {
      const base = {
        name: form.name.trim(),
        serviceType: form.serviceType,
        clientTypeId: form.clientTypeId,
        items: items.map((it, idx) => ({
          id: it.id,
          description: it.description,
          order: idx,
          required: it.required,
        })),
        updatedAt: serverTimestamp(),
      };
      if (form.id) {
        await updateDoc(doc(db, "checklists", form.id), base);
      } else {
        const ref = doc(collection(db, "checklists"));
        await setDoc(ref, {
          ...base,
          companyId,
          description: null,
          clientId: null,
          contractId: null,
          locationId: null,
          isStandard: true,
          ownerId: null,
          sourceId: null,
          active: true,
          createdAt: serverTimestamp(),
        });
      }
      const edited = Boolean(form.id);
      setForm(null);
      await load();
      toast.success(edited ? "Checklist atualizado." : "Checklist cadastrado.");
    } catch (err) {
      toast.error(errorMessage(err, { subscriptionInactive: subInactive }));
    } finally {
      setSaving(false);
    }
  }

  async function onDelete(c: StandardChecklist) {
    setDeleting(true);
    try {
      await deleteDoc(doc(db, "checklists", c.id));
      setConfirmDelete(null);
      await load();
      toast.success("Checklist excluído.");
    } catch (err) {
      toast.error(errorMessage(err, { subscriptionInactive: subInactive }));
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Checklists padrão</h1>
          <p className="mt-1 text-sm text-muted">
            Modelos por tipo de cliente. Os supervisores recebem uma cópia
            editável destes.
          </p>
        </div>
        {companyId && (
          <button
            onClick={openNew}
            className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
          >
            Novo checklist
          </button>
        )}
      </div>

      {companyId && !loading && types.length === 0 && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Cadastre um tipo de cliente primeiro (menu “Tipos de cliente”).
        </p>
      )}

      <div className="mt-8">
        {loading ? (
          <Loader />
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : lists.length === 0 ? (
          <p className="rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
            Nenhum checklist padrão cadastrado ainda.
          </p>
        ) : (
          <ul className="divide-y divide-border overflow-hidden rounded-2xl border border-border bg-surface">
            {lists.map((c) => (
              <li key={c.id} className="flex items-center justify-between px-5 py-4">
                <div className="min-w-0">
                  <p className="truncate font-medium">{c.name}</p>
                  <p className="truncate text-sm text-muted">
                    {serviceTypeLabel(c.serviceType)}
                    {" · "}
                    {c.clientTypeId
                      ? (typeNames.get(c.clientTypeId) ?? "—")
                      : "—"}
                    {" · "}
                    {c.items.length} item(ns)
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openEdit(c)}
                    title="Editar"
                    aria-label="Editar"
                    className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
                  >
                    <EditIcon />
                  </button>
                  <button
                    onClick={() => setConfirmDelete(c)}
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

      {/* Form builder */}
      {form && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => !saving && setForm(null)}
        >
          <form
            onSubmit={onSave}
            onClick={(e) => e.stopPropagation()}
            className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-surface p-6 shadow-lg"
          >
            <h2 className="text-lg font-semibold">
              {form.id ? "Editar checklist padrão" : "Novo checklist padrão"}
            </h2>

            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <label className="block text-sm font-medium sm:col-span-2">
                Nome
                <input
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                />
              </label>
              <label className="block text-sm font-medium">
                Tipo de serviço
                <select
                  value={form.serviceType}
                  onChange={(e) =>
                    setForm({ ...form, serviceType: e.target.value as ServiceType })
                  }
                  className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  {SERVICE_TYPES.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block text-sm font-medium">
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
                  {types.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.name}
                    </option>
                  ))}
                </select>
              </label>
            </div>

            <div className="mt-5">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-sm font-medium">Itens</span>
                <button
                  type="button"
                  onClick={() =>
                    setForm({
                      ...form,
                      items: [
                        ...form.items,
                        { id: newId(), description: "", required: true },
                      ],
                    })
                  }
                  className="rounded-lg border border-border px-3 py-1 text-sm font-medium hover:bg-surface-2"
                >
                  + Adicionar item
                </button>
              </div>
              <ul className="space-y-2">
                {form.items.map((it, i) => (
                  <li
                    key={it.id}
                    className="flex items-center gap-2 rounded-lg border border-border p-2"
                  >
                    <div className="flex flex-col">
                      <button
                        type="button"
                        onClick={() => moveItem(i, -1)}
                        disabled={i === 0}
                        className="px-1 text-muted hover:text-brand disabled:opacity-30"
                        aria-label="Subir"
                      >
                        ↑
                      </button>
                      <button
                        type="button"
                        onClick={() => moveItem(i, 1)}
                        disabled={i === form.items.length - 1}
                        className="px-1 text-muted hover:text-brand disabled:opacity-30"
                        aria-label="Descer"
                      >
                        ↓
                      </button>
                    </div>
                    <input
                      value={it.description}
                      onChange={(e) => patchItem(i, { description: e.target.value })}
                      placeholder={`Item ${i + 1}`}
                      className="flex-1 rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                    />
                    <label className="flex items-center gap-1 text-xs text-muted">
                      <input
                        type="checkbox"
                        checked={it.required}
                        onChange={(e) =>
                          patchItem(i, { required: e.target.checked })
                        }
                        className="h-4 w-4 rounded border-border text-brand focus:ring-brand"
                      />
                      obrig.
                    </label>
                    <button
                      type="button"
                      onClick={() =>
                        setForm({
                          ...form,
                          items: form.items.filter((_, j) => j !== i),
                        })
                      }
                      className="rounded-lg p-1 text-red-600 hover:bg-red-50"
                      aria-label="Remover item"
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  </li>
                ))}
              </ul>
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
                disabled={saving || types.length === 0}
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
            <h2 className="text-lg font-semibold">Excluir checklist padrão</h2>
            <p className="mt-2 text-sm text-muted">
              Excluir <span className="font-medium">{confirmDelete.name}</span>?
              As cópias já feitas pelos supervisores não são afetadas.
            </p>
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
