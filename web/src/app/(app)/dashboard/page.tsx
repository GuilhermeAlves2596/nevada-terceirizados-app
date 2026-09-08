"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";

export default function DashboardPage() {
  const { profile } = useAuth();

  return (
    <div>
      <h1 className="text-2xl font-semibold">
        Olá, {profile?.name ?? "gestor"}
      </h1>
      <p className="mt-1 text-sm text-slate-500">
        Painel de gestão da empresa.
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Link
          href="/supervisors"
          className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:border-brand"
        >
          <h2 className="font-medium">Supervisores</h2>
          <p className="mt-1 text-sm text-slate-500">
            Cadastrar supervisores e vincular contratos.
          </p>
        </Link>

        <div className="rounded-2xl border border-dashed border-slate-200 p-5 text-slate-400">
          <h2 className="font-medium">Clientes</h2>
          <p className="mt-1 text-sm">Em breve.</p>
        </div>

        <Link
          href="/contracts"
          className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:border-brand"
        >
          <h2 className="font-medium">Contratos</h2>
          <p className="mt-1 text-sm text-slate-500">
            Cadastrar e gerenciar contratos por cliente.
          </p>
        </Link>
      </div>
    </div>
  );
}
