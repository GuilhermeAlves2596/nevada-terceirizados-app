"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { useTheme } from "@/lib/theme";
import { Loader } from "@/components/spinner";
import {
  BuildingIcon,
  ChartIcon,
  ChecklistIcon,
  CompaniesIcon,
  FileIcon,
  HomeIcon,
  LogoutIcon,
  MenuIcon,
  MoonIcon,
  SunIcon,
  TagIcon,
  UsersIcon,
  XIcon,
} from "@/components/icons";

const MANAGER_ROLES = ["companyAdmin", "platformAdmin"];

const NAV = [
  { href: "/dashboard", label: "Início", icon: HomeIcon },
  { href: "/supervisors", label: "Supervisores", icon: UsersIcon },
  { href: "/clients", label: "Clientes", icon: BuildingIcon },
  { href: "/client-types", label: "Tipos de cliente", icon: TagIcon },
  { href: "/standard-checklists", label: "Checklists padrão", icon: ChecklistIcon },
  { href: "/contracts", label: "Contratos", icon: FileIcon },
  { href: "/reports", label: "Relatórios", icon: ChartIcon },
];

// Item exclusivo do admin da plataforma (gestão de empresas/tenants).
const PLATFORM_NAV = {
  href: "/companies",
  label: "Empresas",
  icon: CompaniesIcon,
};

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, profile, subscriptionActive, loading, signOut } = useAuth();
  const { theme, toggle } = useTheme();
  const router = useRouter();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.replace("/login");
      return;
    }
    // 1º acesso: força a troca da senha temporária antes de usar o painel.
    if (profile?.mustChangePassword) {
      router.replace("/change-password");
    }
  }, [user, profile, loading, router]);

  // Fecha o drawer ao navegar.
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  if (loading) {
    return <Loader full />;
  }
  if (!user) return null;

  if (!profile || !MANAGER_ROLES.includes(profile.role)) {
    return (
      <div className="mx-auto mt-24 max-w-md rounded-2xl border border-border bg-surface p-8 text-center shadow-sm">
        <h1 className="text-lg font-semibold">Acesso restrito</h1>
        <p className="mt-2 text-sm text-muted">
          Este painel é exclusivo para gestores da empresa.
        </p>
        <button
          onClick={() => signOut()}
          className="mt-5 rounded-lg border border-border px-4 py-2 text-sm font-medium hover:bg-surface-2"
        >
          Sair
        </button>
      </div>
    );
  }

  // platformAdmin ganha "Empresas" logo após "Início".
  const nav =
    profile.role === "platformAdmin"
      ? [NAV[0], PLATFORM_NAV, ...NAV.slice(1)]
      : NAV;

  const initials = (profile.name ?? profile.email ?? "?")
    .split(" ")
    .slice(0, 2)
    .map((s) => s[0]?.toUpperCase() ?? "")
    .join("");

  return (
    <div className="min-h-screen">
      {/* Overlay do drawer (mobile) */}
      {open && (
        <div
          className="fixed inset-0 z-30 bg-black/40 md:hidden"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed inset-y-0 left-0 z-40 flex w-60 transform flex-col border-r border-border bg-surface transition-transform md:translate-x-0 ${
          open ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex items-center justify-between px-5 py-4">
          <div className="flex items-center gap-2">
            <div className="grid h-8 w-8 place-items-center rounded-lg bg-brand text-sm font-bold text-white">
              N
            </div>
            <span className="font-semibold text-brand-dark dark:text-fg">
              Nevada
            </span>
          </div>
          <button
            onClick={() => setOpen(false)}
            className="rounded-lg p-1 text-muted hover:bg-surface-2 md:hidden"
            aria-label="Fechar menu"
          >
            <XIcon />
          </button>
        </div>

        <nav className="flex-1 space-y-1 px-3 py-2">
          {nav.map((item) => {
            const active =
              pathname === item.href || pathname.startsWith(item.href + "/");
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition ${
                  active
                    ? "bg-brand-soft text-brand-dark dark:text-fg"
                    : "text-muted hover:bg-surface-2 hover:text-fg"
                }`}
              >
                <Icon />
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Rodapé: tema + usuário + sair */}
        <div className="border-t border-border p-3">
          <button
            onClick={toggle}
            className="mb-2 flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-muted hover:bg-surface-2 hover:text-fg"
          >
            {theme === "dark" ? <SunIcon /> : <MoonIcon />}
            {theme === "dark" ? "Tema claro" : "Tema escuro"}
          </button>
          <div className="flex items-center gap-1">
            <Link
              href="/profile"
              title="Meu perfil"
              className={`flex min-w-0 flex-1 items-center gap-3 rounded-lg px-2 py-2 hover:bg-surface-2 ${
                pathname === "/profile" ? "bg-surface-2" : ""
              }`}
            >
              <div className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-brand-soft text-xs font-semibold text-brand-dark dark:text-fg">
                {initials}
              </div>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium">
                  {profile.name?.trim()
                    ? profile.name
                    : profile.role === "platformAdmin"
                      ? "Administrador"
                      : "Gestor"}
                </p>
                <p className="truncate text-xs text-muted">
                {user.email ?? profile.email}
              </p>
              </div>
            </Link>
            <button
              onClick={() => signOut()}
              className="shrink-0 rounded-lg p-1.5 text-muted hover:bg-surface-2 hover:text-fg"
              title="Sair"
              aria-label="Sair"
            >
              <LogoutIcon />
            </button>
          </div>
        </div>
      </aside>

      {/* Conteúdo */}
      <div className="md:pl-60">
        {/* Topbar mobile */}
        <header className="sticky top-0 z-20 flex items-center gap-3 border-b border-border bg-surface/80 px-4 py-3 backdrop-blur md:hidden">
          <button
            onClick={() => setOpen(true)}
            className="rounded-lg p-1 text-muted hover:bg-surface-2"
            aria-label="Abrir menu"
          >
            <MenuIcon />
          </button>
          <span className="font-semibold text-brand-dark dark:text-fg">
            Nevada
          </span>
        </header>

        <main className="mx-auto max-w-6xl px-4 py-6 sm:px-6 lg:px-8">
          {subscriptionActive === false && (
            <div className="mb-6 rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-sm text-amber-800 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-200">
              A assinatura da empresa está <strong>inativa</strong>. Cadastros e
              alterações ficam bloqueados até a assinatura ser regularizada.
            </div>
          )}
          {children}
        </main>
      </div>
    </div>
  );
}
