"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import {
  collection,
  doc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { useToast } from "@/lib/toast";
import { errorMessage } from "@/lib/errors";
import { Loader } from "@/components/spinner";
import {
  fetchCompanies,
  isKnownPlan,
  planLabel,
  planSeats,
  PLANS,
  SUBSCRIPTION_STATUSES,
  subscriptionGrantsAccess,
  subscriptionStatusLabel,
  type Company,
  type PlanTier,
  type SubscriptionStatus,
} from "@/lib/model";
import { EditIcon, UsersIcon } from "@/components/icons";

type FormState = {
  id: string | null; // null = nova empresa
  name: string;
  document: string;
  plan: PlanTier | "";
  subscriptionStatus: SubscriptionStatus;
};

const EMPTY_FORM: FormState = {
  id: null,
  name: "",
  document: "",
  plan: "",
  subscriptionStatus: "trial",
};

export default function CompaniesPage() {
  const { profile } = useAuth();
  const isPlatformAdmin = profile?.role === "platformAdmin";
  const toast = useToast();

  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!isPlatformAdmin) {
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      setCompanies(await fetchCompanies());
    } catch {
      setLoadError("Não foi possível carregar as empresas.");
    } finally {
      setLoading(false);
    }
  }, [isPlatformAdmin]);

  useEffect(() => {
    load();
  }, [load]);

  function openNew() {
    setFormError(null);
    setForm({ ...EMPTY_FORM });
  }

  function openEdit(c: Company) {
    setFormError(null);
    setForm({
      id: c.id,
      name: c.name ?? "",
      document: c.document ?? "",
      plan: (c.plan as PlanTier) ?? "",
      subscriptionStatus:
        (c.subscriptionStatus as SubscriptionStatus) ?? "trial",
    });
  }

  async function onSave(e: React.FormEvent) {
    e.preventDefault();
    if (!form) return;
    if (!form.name.trim() || !form.document.trim() || !form.plan) {
      setFormError("Preencha todos os campos.");
      return;
    }
    if (!isKnownPlan(form.plan)) {
      setFormError("Plano inválido.");
      return;
    }
    // Assentos vêm do plano (níveis fixos definem o limite). null = ilimitado.
    const seatsNum = planSeats(form.plan);
    setFormError(null);
    setSaving(true);
    try {
      const base = {
        name: form.name.trim(),
        document: form.document.trim(),
        plan: form.plan,
        subscriptionStatus: form.subscriptionStatus,
        seats: seatsNum,
        // Mantido por coerência: espelha o status (o gate real é o status).
        active: subscriptionGrantsAccess(form.subscriptionStatus),
        updatedAt: serverTimestamp(),
      };
      const edited = Boolean(form.id);
      if (form.id) {
        await updateDoc(doc(db, "companies", form.id), base);
      } else {
        const ref = doc(collection(db, "companies"));
        await setDoc(ref, { ...base, createdAt: serverTimestamp() });
      }
      setForm(null);
      await load();
      toast.success(edited ? "Empresa atualizada." : "Empresa cadastrada.");
    } catch (err) {
      toast.error(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  if (!isPlatformAdmin) {
    return (
      <div className="mx-auto mt-16 max-w-md rounded-2xl border border-border bg-surface p-8 text-center">
        <h1 className="text-lg font-semibold">Acesso restrito</h1>
        <p className="mt-2 text-sm text-muted">
          Só o administrador da plataforma gerencia empresas.
        </p>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Empresas</h1>
          <p className="mt-1 text-sm text-muted">
            Tenants da plataforma. O status da assinatura controla o acesso da
            empresa.
          </p>
        </div>
        <button
          onClick={openNew}
          className="rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
        >
          Nova empresa
        </button>
      </div>

      <div className="mt-8">
        {loading ? (
          <Loader />
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : companies.length === 0 ? (
          <p className="rounded-lg border border-dashed border-border p-6 text-center text-sm text-muted">
            Nenhuma empresa cadastrada ainda.
          </p>
        ) : (
          <div className="overflow-hidden rounded-2xl border border-border bg-surface">
            <table className="w-full text-sm">
              <thead className="bg-surface-2 text-left text-xs uppercase tracking-wide text-muted">
                <tr>
                  <th className="px-5 py-3 font-medium">Empresa</th>
                  <th className="hidden px-5 py-3 font-medium sm:table-cell">
                    Documento
                  </th>
                  <th className="hidden px-5 py-3 font-medium md:table-cell">
                    Plano
                  </th>
                  <th className="hidden px-5 py-3 font-medium lg:table-cell">
                    Assentos
                  </th>
                  <th className="px-5 py-3 font-medium">Assinatura</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {companies.map((c) => (
                  <tr key={c.id}>
                    <td className="px-5 py-3">
                      <Link
                        href={`/companies/${c.id}`}
                        className="font-medium hover:text-brand hover:underline"
                      >
                        {c.name}
                      </Link>
                    </td>
                    <td className="hidden px-5 py-3 text-muted sm:table-cell">
                      {c.document || "—"}
                    </td>
                    <td className="hidden px-5 py-3 text-muted md:table-cell">
                      {c.plan ? planLabel(c.plan) : "—"}
                    </td>
                    <td className="hidden px-5 py-3 text-muted lg:table-cell">
                      {c.seats != null
                        ? c.seats
                        : c.plan === "unlimited"
                          ? "Ilimitado"
                          : "—"}
                    </td>
                    <td className="px-5 py-3">
                      <span
                        className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${
                          subscriptionGrantsAccess(c.subscriptionStatus)
                            ? "bg-green-100 text-green-700"
                            : "bg-red-100 text-red-700"
                        }`}
                      >
                        {subscriptionStatusLabel(c.subscriptionStatus)}
                      </span>
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex justify-end gap-2">
                        <Link
                          href={`/companies/${c.id}`}
                          title="Gestores"
                          aria-label="Gestores"
                          className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
                        >
                          <UsersIcon />
                        </Link>
                        <button
                          onClick={() => openEdit(c)}
                          title="Editar"
                          aria-label="Editar"
                          className="rounded-lg border border-border p-2 text-muted hover:bg-surface-2 hover:text-brand"
                        >
                          <EditIcon />
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

      {/* Form de empresa (nova/editar) */}
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
              {form.id ? "Editar empresa" : "Nova empresa"}
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
                CNPJ
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
                Plano
                <select
                  required
                  value={form.plan}
                  onChange={(e) =>
                    setForm({ ...form, plan: e.target.value as PlanTier })
                  }
                  className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  <option value="" disabled>
                    Selecione…
                  </option>
                  {PLANS.map((p) => (
                    <option key={p.value} value={p.value}>
                      {p.label}
                      {p.seats == null
                        ? " — ilimitado"
                        : ` — até ${p.seats} contas`}
                    </option>
                  ))}
                </select>
              </label>

              <label className="block text-sm font-medium text-fg">
                Assentos (definido pelo plano)
                <input
                  readOnly
                  disabled
                  value={
                    !form.plan
                      ? "—"
                      : planSeats(form.plan) == null
                        ? "Ilimitado"
                        : `${planSeats(form.plan)} contas`
                  }
                  className="mt-1 w-full rounded-lg border border-border bg-surface-2 px-3 py-2 text-sm text-muted outline-none"
                />
              </label>

              <label className="block text-sm font-medium text-fg sm:col-span-2">
                Status da assinatura
                <select
                  value={form.subscriptionStatus}
                  onChange={(e) =>
                    setForm({
                      ...form,
                      subscriptionStatus: e.target.value as SubscriptionStatus,
                    })
                  }
                  className="mt-1 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
                >
                  {SUBSCRIPTION_STATUSES.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </label>

            </div>

            <p className="mt-3 text-xs text-muted">
              Suspenda ou cancele a assinatura para bloquear o acesso da empresa
              — os dados são preservados.
            </p>
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
    </div>
  );
}
