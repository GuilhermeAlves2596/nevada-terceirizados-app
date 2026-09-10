"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { createPortal } from "react-dom";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { useAuth } from "@/lib/auth-context";
import { useTheme } from "@/lib/theme";
import {
  fetchCompletedExecutions,
  fetchContracts,
  fetchTasks,
  fetchUsers,
  tsToDate,
  type TaskExecutionLite,
  type TaskLite,
} from "@/lib/model";
import { ChevronLeftIcon, ChevronRightIcon } from "@/components/icons";
import { Loader } from "@/components/spinner";

type Exec = {
  date: Date;
  contract: string;
  employee: string;
  photos: number;
};

const MONTHS = [
  "janeiro", "fevereiro", "março", "abril", "maio", "junho",
  "julho", "agosto", "setembro", "outubro", "novembro", "dezembro",
];

export default function DashboardPage() {
  const { profile } = useAuth();
  const { theme } = useTheme();
  const companyId = profile?.companyId ?? null;

  const [executions, setExecutions] = useState<TaskExecutionLite[]>([]);
  const [tasks, setTasks] = useState<Map<string, TaskLite>>(new Map());
  const [contractNames, setContractNames] = useState<Map<string, string>>(new Map());
  const [userNames, setUserNames] = useState<Map<string, string>>(new Map());
  const [loading, setLoading] = useState(true);
  const [mounted, setMounted] = useState(false);
  const [printing, setPrinting] = useState(false);

  const now = useMemo(() => new Date(), []);
  const [ref, setRef] = useState(() => ({
    y: now.getFullYear(),
    m: now.getMonth(),
  }));

  useEffect(() => setMounted(true), []);

  const load = useCallback(async () => {
    if (!companyId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const [execs, tks, contracts, users] = await Promise.all([
        fetchCompletedExecutions(companyId),
        fetchTasks(companyId),
        fetchContracts(companyId),
        fetchUsers(companyId),
      ]);
      setExecutions(execs);
      setTasks(new Map(tks.map((t) => [t.id, t])));
      setContractNames(new Map(contracts.map((c) => [c.id, c.name])));
      setUserNames(new Map(users.map((u) => [u.id, u.name ?? "—"])));
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  // Execuções do mês selecionado.
  const monthExecs = useMemo<Exec[]>(() => {
    const out: Exec[] = [];
    for (const e of executions) {
      const date = tsToDate(e.finishedAt) ?? tsToDate(e.startedAt);
      if (!date) continue;
      if (date.getFullYear() !== ref.y || date.getMonth() !== ref.m) continue;
      const task = tasks.get(e.taskId);
      out.push({
        date,
        contract: task ? contractNames.get(task.contractId) ?? "—" : "—",
        employee: userNames.get(e.employeeId) ?? "—",
        photos: e.photos.filter((p) => p.downloadUrl).length,
      });
    }
    return out;
  }, [executions, tasks, contractNames, userNames, ref]);

  const daysInMonth = new Date(ref.y, ref.m + 1, 0).getDate();

  const perDay = useMemo(() => {
    const arr = Array.from({ length: daysInMonth }, (_, i) => ({
      day: String(i + 1),
      count: 0,
    }));
    for (const e of monthExecs) arr[e.date.getDate() - 1].count += 1;
    return arr;
  }, [monthExecs, daysInMonth]);

  const perContract = useMemo(() => byKey(monthExecs, (e) => e.contract), [monthExecs]);
  const perEmployee = useMemo(() => byKey(monthExecs, (e) => e.employee), [monthExecs]);

  const kpis = useMemo(() => {
    const photos = monthExecs.reduce((n, e) => n + e.photos, 0);
    const emps = new Set(monthExecs.map((e) => e.employee)).size;
    const contracts = new Set(monthExecs.map((e) => e.contract)).size;
    return { total: monthExecs.length, photos, emps, contracts };
  }, [monthExecs]);

  const dark = theme === "dark";
  const c = {
    axis: dark ? "#94a3b8" : "#64748b",
    grid: dark ? "#334155" : "#e2e8f0",
    bar: dark ? "#60a5fa" : "#1D4F91",
    bar2: dark ? "#34d399" : "#0f766e",
    tipBg: dark ? "#1e293b" : "#ffffff",
    tipBorder: dark ? "#334155" : "#e2e8f0",
    tipText: dark ? "#e2e8f0" : "#0f172a",
  };

  const canNext =
    ref.y < now.getFullYear() ||
    (ref.y === now.getFullYear() && ref.m < now.getMonth());

  const goPrev = () =>
    setRef((r) => {
      const d = new Date(r.y, r.m - 1, 1);
      return { y: d.getFullYear(), m: d.getMonth() };
    });
  const goNext = () =>
    setRef((r) => {
      if (
        r.y > now.getFullYear() ||
        (r.y === now.getFullYear() && r.m >= now.getMonth())
      )
        return r;
      const d = new Date(r.y, r.m + 1, 1);
      return { y: d.getFullYear(), m: d.getMonth() };
    });

  const monthLabel = `${MONTHS[ref.m]} de ${ref.y}`;

  // Export PDF (impressão).
  useEffect(() => {
    if (!printing) return;
    const onAfter = () => setPrinting(false);
    window.addEventListener("afterprint", onAfter);
    const id = window.setTimeout(() => window.print(), 300);
    return () => {
      window.removeEventListener("afterprint", onAfter);
      window.clearTimeout(id);
    };
  }, [printing]);

  const tooltip = (
    <Tooltip
      cursor={{ fill: dark ? "#33415555" : "#e2e8f055" }}
      contentStyle={{
        background: c.tipBg,
        border: `1px solid ${c.tipBorder}`,
        borderRadius: 8,
        color: c.tipText,
        fontSize: 12,
      }}
      labelStyle={{ color: c.tipText }}
    />
  );

  return (
    <div>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">
            Olá,{" "}
            {profile?.name?.trim()
              ? profile.name
              : profile?.role === "platformAdmin"
                ? "administrador"
                : "gestor"}
          </h1>
          <p className="mt-1 text-sm text-muted">Atividades de {monthLabel}.</p>
        </div>
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1 rounded-lg border border-border bg-surface p-1">
            <button
              onClick={goPrev}
              className="rounded-md p-1.5 text-muted hover:bg-surface-2 hover:text-fg"
              aria-label="Mês anterior"
            >
              <ChevronLeftIcon />
            </button>
            <span className="min-w-[9rem] text-center text-sm font-medium capitalize">
              {monthLabel}
            </span>
            <button
              onClick={goNext}
              disabled={!canNext}
              className="rounded-md p-1.5 text-muted hover:bg-surface-2 hover:text-fg disabled:opacity-40"
              aria-label="Próximo mês"
            >
              <ChevronRightIcon />
            </button>
          </div>
          {!loading && kpis.total > 0 && (
            <button
              onClick={() => setPrinting(true)}
              className="rounded-lg border border-border px-4 py-2 text-sm font-medium hover:bg-surface-2"
            >
              Exportar PDF
            </button>
          )}
        </div>
      </div>

      {loading ? (
        <Loader />
      ) : (
        <>
          {/* KPIs */}
          <div className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <Kpi label="Tarefas executadas" value={kpis.total} />
            <Kpi label="Fotos registradas" value={kpis.photos} />
            <Kpi label="Funcionários ativos" value={kpis.emps} />
            <Kpi label="Contratos com atividade" value={kpis.contracts} />
          </div>

          {kpis.total === 0 ? (
            <p className="mt-6 rounded-2xl border border-dashed border-border p-8 text-center text-sm text-muted">
              Nenhuma tarefa executada em {monthLabel}.
            </p>
          ) : (
            <div className="mt-6 grid gap-4 lg:grid-cols-2">
              <Panel title="Execuções por dia" className="lg:col-span-2">
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart data={perDay} margin={{ top: 8, right: 8, left: -18, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke={c.grid} vertical={false} />
                    <XAxis dataKey="day" tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={{ stroke: c.grid }} interval={2} />
                    <YAxis allowDecimals={false} tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={false} width={28} />
                    {tooltip}
                    <Bar dataKey="count" name="Tarefas" fill={c.bar} radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </Panel>

              <Panel title="Por contrato">
                <ResponsiveContainer width="100%" height={Math.max(200, perContract.length * 38)}>
                  <BarChart data={perContract} layout="vertical" margin={{ top: 4, right: 16, left: 8, bottom: 4 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke={c.grid} horizontal={false} />
                    <XAxis type="number" allowDecimals={false} tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={false} />
                    <YAxis type="category" dataKey="name" width={110} tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={false} />
                    {tooltip}
                    <Bar dataKey="count" name="Tarefas" fill={c.bar} radius={[0, 4, 4, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </Panel>

              <Panel title="Por funcionário">
                <ResponsiveContainer width="100%" height={Math.max(200, perEmployee.length * 38)}>
                  <BarChart data={perEmployee} layout="vertical" margin={{ top: 4, right: 16, left: 8, bottom: 4 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke={c.grid} horizontal={false} />
                    <XAxis type="number" allowDecimals={false} tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={false} />
                    <YAxis type="category" dataKey="name" width={110} tick={{ fill: c.axis, fontSize: 11 }} tickLine={false} axisLine={false} />
                    {tooltip}
                    <Bar dataKey="count" name="Tarefas" fill={c.bar2} radius={[0, 4, 4, 0]}>
                      {perEmployee.map((_, i) => (
                        <Cell key={i} fill={c.bar2} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </Panel>
            </div>
          )}
        </>
      )}

      {/* Impressão (PDF) — gráficos com tamanho fixo p/ renderizar fora de tela */}
      {mounted &&
        printing &&
        createPortal(
          <div id="print-root">
            <h1 style={{ fontSize: 20, fontWeight: 700 }}>
              Atividades — {monthLabel}
            </h1>
            <table style={{ marginTop: 10, fontSize: 12, borderCollapse: "collapse" }}>
              <tbody>
                {[
                  ["Tarefas executadas", kpis.total],
                  ["Fotos registradas", kpis.photos],
                  ["Funcionários ativos", kpis.emps],
                  ["Contratos com atividade", kpis.contracts],
                ].map(([k, v]) => (
                  <tr key={String(k)}>
                    <td style={{ padding: "2px 16px 2px 0", color: "#475569" }}>{k}</td>
                    <td style={{ padding: "2px 0", fontWeight: 600 }}>{v}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            <h2 style={{ fontSize: 14, fontWeight: 600, marginTop: 16 }}>Execuções por dia</h2>
            <BarChart width={680} height={220} data={perDay} margin={{ top: 8, right: 8, left: -18, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
              <XAxis dataKey="day" tick={{ fill: "#64748b", fontSize: 10 }} interval={1} />
              <YAxis allowDecimals={false} tick={{ fill: "#64748b", fontSize: 10 }} width={24} />
              <Bar dataKey="count" fill="#1D4F91" radius={[3, 3, 0, 0]} isAnimationActive={false} />
            </BarChart>

            <h2 style={{ fontSize: 14, fontWeight: 600, marginTop: 16 }}>Por contrato</h2>
            <BarChart width={680} height={Math.max(160, perContract.length * 32)} data={perContract} layout="vertical" margin={{ top: 4, right: 16, left: 8, bottom: 4 }}>
              <XAxis type="number" allowDecimals={false} tick={{ fill: "#64748b", fontSize: 10 }} />
              <YAxis type="category" dataKey="name" width={140} tick={{ fill: "#64748b", fontSize: 10 }} />
              <Bar dataKey="count" fill="#1D4F91" radius={[0, 3, 3, 0]} isAnimationActive={false} />
            </BarChart>

            <h2 style={{ fontSize: 14, fontWeight: 600, marginTop: 16 }}>Por funcionário</h2>
            <BarChart width={680} height={Math.max(160, perEmployee.length * 32)} data={perEmployee} layout="vertical" margin={{ top: 4, right: 16, left: 8, bottom: 4 }}>
              <XAxis type="number" allowDecimals={false} tick={{ fill: "#64748b", fontSize: 10 }} />
              <YAxis type="category" dataKey="name" width={140} tick={{ fill: "#64748b", fontSize: 10 }} />
              <Bar dataKey="count" fill="#0f766e" radius={[0, 3, 3, 0]} isAnimationActive={false} />
            </BarChart>
          </div>,
          document.body,
        )}
    </div>
  );
}

function byKey(execs: Exec[], key: (e: Exec) => string) {
  const m = new Map<string, number>();
  for (const e of execs) m.set(key(e), (m.get(key(e)) ?? 0) + 1);
  return Array.from(m.entries())
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 8);
}

function Kpi({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-2xl border border-border bg-surface p-4">
      <p className="text-sm text-muted">{label}</p>
      <p className="mt-1 text-2xl font-semibold">{value}</p>
    </div>
  );
}

function Panel({
  title,
  className,
  children,
}: {
  title: string;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div className={`rounded-2xl border border-border bg-surface p-4 ${className ?? ""}`}>
      <h2 className="mb-3 text-sm font-medium text-muted">{title}</h2>
      {children}
    </div>
  );
}
