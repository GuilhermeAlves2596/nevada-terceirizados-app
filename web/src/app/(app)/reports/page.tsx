"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { createPortal } from "react-dom";
import { useAuth } from "@/lib/auth-context";
import {
  fetchChecklists,
  fetchClients,
  fetchCompletedExecutions,
  fetchContracts,
  fetchLocations,
  fetchTasks,
  fetchUsers,
  tsToDate,
  type ExecItem,
  type TaskExecutionLite,
  type TaskLite,
} from "@/lib/model";

/** JS Date → "YYYY-MM-DD" (local). */
function dateInput(d: Date): string {
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${m}-${day}`;
}

function fmtDate(d: Date | null): string {
  return d ? d.toLocaleDateString("pt-BR") : "—";
}
function fmtDateTime(d: Date | null): string {
  return d
    ? d.toLocaleString("pt-BR", { dateStyle: "short", timeStyle: "short" })
    : "—";
}

type Row = {
  id: string;
  date: Date | null;
  dateStr: string;
  startedAt: Date | null;
  finishedAt: Date | null;
  title: string;
  location: string;
  contractId: string;
  contract: string;
  client: string;
  employeeId: string;
  employee: string;
  observation?: string | null;
  items: ExecItem[];
  photos: string[];
};

export default function ReportsPage() {
  const { profile } = useAuth();
  const companyId = profile?.companyId ?? null;

  const [executions, setExecutions] = useState<TaskExecutionLite[]>([]);
  const [tasks, setTasks] = useState<Map<string, TaskLite>>(new Map());
  const [contractNames, setContractNames] = useState<Map<string, string>>(new Map());
  const [contractList, setContractList] = useState<{ id: string; name: string }[]>([]);
  const [clientNames, setClientNames] = useState<Map<string, string>>(new Map());
  const [userNames, setUserNames] = useState<Map<string, string>>(new Map());
  const [employees, setEmployees] = useState<{ id: string; name: string }[]>([]);
  const [checklistNames, setChecklistNames] = useState<Map<string, string>>(new Map());
  const [locationNames, setLocationNames] = useState<Map<string, string>>(new Map());
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const today = useMemo(() => new Date(), []);
  const [startDate, setStartDate] = useState(() => {
    const d = new Date();
    d.setDate(d.getDate() - 30);
    return dateInput(d);
  });
  const [endDate, setEndDate] = useState(() => dateInput(new Date()));
  const [contractFilter, setContractFilter] = useState("");
  const [employeeFilter, setEmployeeFilter] = useState("");

  const [detail, setDetail] = useState<Row | null>(null);
  const [lightbox, setLightbox] = useState<string | null>(null);
  const [printTarget, setPrintTarget] = useState<
    { type: "all" } | { type: "one"; row: Row } | null
  >(null);
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const load = useCallback(async () => {
    if (!companyId) {
      setExecutions([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    setLoadError(null);
    try {
      const [execs, tks, contracts, clients, users, checklists, locations] =
        await Promise.all([
          fetchCompletedExecutions(companyId),
          fetchTasks(companyId),
          fetchContracts(companyId),
          fetchClients(companyId),
          fetchUsers(companyId),
          fetchChecklists(companyId),
          fetchLocations(companyId),
        ]);
      setExecutions(execs);
      setTasks(new Map(tks.map((t) => [t.id, t])));
      setContractNames(new Map(contracts.map((c) => [c.id, c.name])));
      setContractList(contracts.map((c) => ({ id: c.id, name: c.name })));
      setClientNames(new Map(clients.map((c) => [c.id, c.name])));
      setUserNames(new Map(users.map((u) => [u.id, u.name ?? "—"])));
      setEmployees(
        users
          .filter((u) => u.role === "employee")
          .map((u) => ({ id: u.id, name: u.name ?? "—" }))
          .sort((a, b) => a.name.localeCompare(b.name)),
      );
      setChecklistNames(new Map(checklists.map((c) => [c.id, c.name])));
      setLocationNames(new Map(locations.map((l) => [l.id, l.name])));
    } catch {
      setLoadError("Não foi possível carregar o relatório.");
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    load();
  }, [load]);

  const rows = useMemo<Row[]>(() => {
    const out: Row[] = [];
    for (const e of executions) {
      const task = tasks.get(e.taskId);
      const finished = tsToDate(e.finishedAt);
      const started = tsToDate(e.startedAt);
      const date = finished ?? started;
      out.push({
        id: e.id,
        date,
        dateStr: date ? dateInput(date) : "",
        startedAt: started,
        finishedAt: finished,
        title: task ? checklistNames.get(task.checklistId) ?? "Tarefa" : "Tarefa",
        location: task ? locationNames.get(task.locationId) ?? "" : "",
        contractId: task?.contractId ?? "",
        contract: task ? contractNames.get(task.contractId) ?? "—" : "—",
        client: task ? clientNames.get(task.clientId) ?? "—" : "—",
        employeeId: e.employeeId,
        employee: userNames.get(e.employeeId) ?? "—",
        observation: e.observation,
        items: e.items,
        photos: e.photos
          .map((p) => p.downloadUrl)
          .filter((u): u is string => Boolean(u)),
      });
    }
    return out
      .filter((r) => {
        if (!r.dateStr) return false;
        if (r.dateStr < startDate || r.dateStr > endDate) return false;
        if (contractFilter && r.contractId !== contractFilter) return false;
        if (employeeFilter && r.employeeId !== employeeFilter) return false;
        return true;
      })
      .sort((a, b) => b.dateStr.localeCompare(a.dateStr));
  }, [
    executions,
    tasks,
    checklistNames,
    locationNames,
    contractNames,
    clientNames,
    userNames,
    startDate,
    endDate,
    contractFilter,
    employeeFilter,
  ]);

  // Dispara a impressão quando há um alvo, e limpa ao terminar.
  useEffect(() => {
    if (!printTarget) return;
    const onAfter = () => setPrintTarget(null);
    window.addEventListener("afterprint", onAfter);
    // Pequeno atraso p/ o #print-root renderizar e as imagens carregarem.
    const id = window.setTimeout(() => window.print(), 400);
    return () => {
      window.removeEventListener("afterprint", onAfter);
      window.clearTimeout(id);
    };
  }, [printTarget]);

  const printRows = printTarget
    ? printTarget.type === "all"
      ? rows
      : [printTarget.row]
    : [];

  const periodLabel = `${new Date(`${startDate}T12:00:00`).toLocaleDateString(
    "pt-BR",
  )} a ${new Date(`${endDate}T12:00:00`).toLocaleDateString("pt-BR")}`;

  function clearFilters() {
    const from = new Date();
    from.setDate(from.getDate() - 30);
    setStartDate(dateInput(from));
    setEndDate(dateInput(new Date()));
    setContractFilter("");
    setEmployeeFilter("");
  }

  return (
    <div>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Relatórios</h1>
          <p className="mt-1 text-sm text-slate-500">
            Tarefas executadas por período, contrato e funcionário.
          </p>
        </div>
        {companyId && rows.length > 0 && (
          <button
            onClick={() => setPrintTarget({ type: "all" })}
            className="rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium hover:bg-slate-50"
          >
            Exportar PDF
          </button>
        )}
      </div>

      {!companyId && (
        <p className="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-800">
          Sua conta não está vinculada a uma empresa.
        </p>
      )}

      {/* Filtros */}
      <div className="mt-6 grid gap-4 rounded-2xl border border-slate-200 bg-white p-4 sm:grid-cols-2 lg:grid-cols-4">
        <label className="block text-sm font-medium text-slate-700">
          De
          <input
            type="date"
            value={startDate}
            max={endDate}
            onChange={(e) => setStartDate(e.target.value)}
            className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          />
        </label>
        <label className="block text-sm font-medium text-slate-700">
          Até
          <input
            type="date"
            value={endDate}
            min={startDate}
            max={dateInput(today)}
            onChange={(e) => setEndDate(e.target.value)}
            className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          />
        </label>
        <label className="block text-sm font-medium text-slate-700">
          Contrato
          <select
            value={contractFilter}
            onChange={(e) => setContractFilter(e.target.value)}
            className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          >
            <option value="">Todos</option>
            {contractList.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </label>
        <label className="block text-sm font-medium text-slate-700">
          Funcionário
          <select
            value={employeeFilter}
            onChange={(e) => setEmployeeFilter(e.target.value)}
            className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand"
          >
            <option value="">Todos</option>
            {employees.map((u) => (
              <option key={u.id} value={u.id}>
                {u.name}
              </option>
            ))}
          </select>
        </label>
      </div>

      <div className="mt-2 flex justify-end">
        <button
          onClick={clearFilters}
          className="text-sm font-medium text-slate-500 hover:text-brand"
        >
          Limpar filtros
        </button>
      </div>

      {!loading && !loadError && (
        <p className="mt-4 text-sm text-slate-500">
          <span className="font-medium text-slate-700">{rows.length}</span>{" "}
          tarefa(s) executada(s)
        </p>
      )}

      {/* Lista (clicável) */}
      <div className="mt-4 space-y-4">
        {loading ? (
          <p className="text-sm text-slate-500">Carregando…</p>
        ) : loadError ? (
          <p className="text-sm text-red-600">{loadError}</p>
        ) : rows.length === 0 ? (
          <p className="rounded-lg border border-dashed border-slate-200 p-6 text-center text-sm text-slate-500">
            Nenhuma tarefa executada no período/filtros selecionados.
          </p>
        ) : (
          rows.map((r) => (
            <button
              key={r.id}
              onClick={() => setDetail(r)}
              className="block w-full rounded-2xl border border-slate-200 bg-white p-5 text-left transition hover:border-brand"
            >
              <div className="flex flex-wrap items-start justify-between gap-2">
                <div>
                  <h2 className="font-medium">
                    {r.title}
                    {r.location && (
                      <span className="text-slate-500"> · {r.location}</span>
                    )}
                  </h2>
                  <p className="mt-0.5 text-sm text-slate-500">
                    {r.contract} · {r.employee}
                  </p>
                </div>
                <span className="text-sm text-slate-500">{fmtDate(r.date)}</span>
              </div>
              {r.photos.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-2">
                  {r.photos.slice(0, 6).map((url, i) => (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      key={i}
                      src={url}
                      alt="Foto da execução"
                      className="h-16 w-16 rounded-lg border border-slate-200 object-cover"
                      loading="lazy"
                    />
                  ))}
                  {r.photos.length > 6 && (
                    <span className="self-center text-xs text-slate-400">
                      +{r.photos.length - 6}
                    </span>
                  )}
                </div>
              )}
            </button>
          ))
        )}
      </div>

      {/* Detalhe da execução */}
      {detail && (
        <div
          className="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/40 p-4"
          onClick={() => setDetail(null)}
        >
          <div
            className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-6 shadow-lg"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between gap-3">
              <div>
                <h2 className="text-lg font-semibold">{detail.title}</h2>
                {detail.location && (
                  <p className="text-sm text-slate-500">{detail.location}</p>
                )}
              </div>
              <button
                onClick={() => setPrintTarget({ type: "one", row: detail })}
                className="shrink-0 rounded-lg border border-slate-300 px-3 py-1.5 text-sm font-medium hover:bg-slate-50"
              >
                Exportar PDF
              </button>
            </div>

            <dl className="mt-4 grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
              <div>
                <dt className="text-slate-500">Cliente</dt>
                <dd>{detail.client}</dd>
              </div>
              <div>
                <dt className="text-slate-500">Contrato</dt>
                <dd>{detail.contract}</dd>
              </div>
              <div>
                <dt className="text-slate-500">Funcionário</dt>
                <dd>{detail.employee}</dd>
              </div>
              <div>
                <dt className="text-slate-500">Conclusão</dt>
                <dd>{fmtDateTime(detail.finishedAt)}</dd>
              </div>
              <div>
                <dt className="text-slate-500">Início</dt>
                <dd>{fmtDateTime(detail.startedAt)}</dd>
              </div>
            </dl>

            {detail.items.length > 0 && (
              <div className="mt-4">
                <h3 className="text-sm font-medium text-slate-700">Checklist</h3>
                <ul className="mt-2 space-y-1 text-sm">
                  {detail.items.map((it, i) => (
                    <li key={it.id ?? i} className="flex items-start gap-2">
                      <span
                        className={
                          it.completed ? "text-green-600" : "text-slate-300"
                        }
                      >
                        {it.completed ? "✓" : "○"}
                      </span>
                      <span className={it.completed ? "" : "text-slate-500"}>
                        {it.description}
                        {it.required && (
                          <span className="text-red-400"> *</span>
                        )}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {detail.observation && (
              <div className="mt-4">
                <h3 className="text-sm font-medium text-slate-700">Observação</h3>
                <p className="mt-1 rounded-lg bg-slate-50 p-3 text-sm text-slate-600">
                  {detail.observation}
                </p>
              </div>
            )}

            {detail.photos.length > 0 && (
              <div className="mt-4">
                <h3 className="text-sm font-medium text-slate-700">
                  Fotos ({detail.photos.length})
                </h3>
                <div className="mt-2 flex flex-wrap gap-2">
                  {detail.photos.map((url, i) => (
                    <button
                      key={i}
                      onClick={() => setLightbox(url)}
                      className="overflow-hidden rounded-lg border border-slate-200"
                      title="Ampliar"
                    >
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img
                        src={url}
                        alt="Foto da execução"
                        className="h-24 w-24 object-cover"
                        loading="lazy"
                      />
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div className="mt-6 text-right">
              <button
                onClick={() => setDetail(null)}
                className="rounded-lg border border-slate-300 px-4 py-1.5 text-sm font-medium hover:bg-slate-50"
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Lightbox */}
      {lightbox && (
        <div
          className="fixed inset-0 z-30 flex items-center justify-center bg-black/70 p-4"
          onClick={() => setLightbox(null)}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={lightbox}
            alt="Foto da execução"
            className="max-h-full max-w-full rounded-lg"
            onClick={(e) => e.stopPropagation()}
          />
        </div>
      )}

      {/* Área de impressão (só aparece no PDF/print) — portada p/ o <body>
          para que os demais elementos possam sair do fluxo com display:none. */}
      {mounted &&
        createPortal(
          <div id="print-root">
            <div className="mb-4">
          <h1 style={{ fontSize: 20, fontWeight: 700 }}>
            Relatório de tarefas executadas
          </h1>
          <p style={{ fontSize: 12, color: "#475569" }}>
            Período: {periodLabel}
            {contractFilter &&
              ` · Contrato: ${contractNames.get(contractFilter) ?? ""}`}
            {employeeFilter &&
              ` · Funcionário: ${userNames.get(employeeFilter) ?? ""}`}
          </p>
          <p style={{ fontSize: 12, color: "#475569" }}>
            {printRows.length} tarefa(s)
          </p>
        </div>

        {printRows.map((r) => (
          <div
            key={r.id}
            className="print-task"
            style={{
              border: "1px solid #e2e8f0",
              borderRadius: 8,
              padding: 12,
              marginBottom: 12,
            }}
          >
            <div style={{ fontSize: 15, fontWeight: 600 }}>
              {r.title}
              {r.location ? ` · ${r.location}` : ""}
            </div>
            <div style={{ fontSize: 12, color: "#475569", marginTop: 2 }}>
              {r.client} · {r.contract} · {r.employee} · {fmtDateTime(r.finishedAt)}
            </div>

            {r.items.length > 0 && (
              <ul style={{ fontSize: 12, marginTop: 8, paddingLeft: 0, listStyle: "none" }}>
                {r.items.map((it, i) => (
                  <li key={it.id ?? i}>
                    {it.completed ? "☑" : "☐"} {it.description}
                  </li>
                ))}
              </ul>
            )}

            {r.observation && (
              <div style={{ fontSize: 12, marginTop: 8 }}>
                <strong>Observação:</strong> {r.observation}
              </div>
            )}

            {r.photos.length > 0 && (
              <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: 8 }}>
                {r.photos.map((url, i) => (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    key={i}
                    src={url}
                    alt="Foto"
                    style={{
                      width: 140,
                      height: 140,
                      objectFit: "cover",
                      border: "1px solid #e2e8f0",
                      borderRadius: 6,
                    }}
                  />
                ))}
              </div>
            )}
          </div>
        ))}
          </div>,
          document.body,
        )}
    </div>
  );
}
