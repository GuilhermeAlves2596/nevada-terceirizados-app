/** Círculo com animação de giro (usa a cor de marca). */
export function Spinner({ className = "h-8 w-8" }: { className?: string }) {
  return (
    <div
      role="status"
      aria-label="Carregando"
      className={`${className} animate-spin rounded-full border-2 border-border border-t-brand`}
    />
  );
}

/** Spinner centralizado numa área — `full` ocupa a tela toda. */
export function Loader({ full = false }: { full?: boolean }) {
  return (
    <div
      className={`flex items-center justify-center ${
        full ? "min-h-screen" : "min-h-[50vh]"
      }`}
    >
      <Spinner className="h-9 w-9" />
    </div>
  );
}
