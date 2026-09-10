"use client";

import {
  createContext,
  useCallback,
  useContext,
  useRef,
  useState,
  type ReactNode,
} from "react";

type ToastType = "success" | "error";
type Toast = { id: number; message: string; type: ToastType };

type ToastCtx = {
  success: (message: string) => void;
  error: (message: string) => void;
  notify: (message: string, type?: ToastType) => void;
};

const ToastContext = createContext<ToastCtx>({
  success: () => {},
  error: () => {},
  notify: () => {},
});

const DURATION = 4000;

/** Notificações efêmeras (canto inferior), tema-aware. */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const idRef = useRef(0);

  const remove = useCallback((id: number) => {
    setToasts((list) => list.filter((t) => t.id !== id));
  }, []);

  const notify = useCallback(
    (message: string, type: ToastType = "success") => {
      const id = (idRef.current += 1);
      setToasts((list) => [...list, { id, message, type }]);
      setTimeout(() => remove(id), DURATION);
    },
    [remove],
  );

  const success = useCallback((m: string) => notify(m, "success"), [notify]);
  const error = useCallback((m: string) => notify(m, "error"), [notify]);

  return (
    <ToastContext.Provider value={{ success, error, notify }}>
      {children}
      <div className="pointer-events-none fixed right-0 top-0 z-50 flex flex-col items-end gap-2 p-4">
        {toasts.map((t) => (
          <div
            key={t.id}
            role="status"
            className={`pointer-events-auto flex w-full max-w-sm items-start gap-3 rounded-xl border px-4 py-3 text-sm shadow-lg ${
              t.type === "error"
                ? "border-red-300 bg-red-50 text-red-800 dark:border-red-900 dark:bg-red-950 dark:text-red-200"
                : "border-green-300 bg-green-50 text-green-800 dark:border-green-900 dark:bg-green-950 dark:text-green-200"
            }`}
          >
            <span className="mt-0.5 shrink-0" aria-hidden="true">
              {t.type === "error" ? (
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  className="h-5 w-5"
                >
                  <circle cx="12" cy="12" r="9" />
                  <path d="M12 8v5M12 16h.01" strokeLinecap="round" />
                </svg>
              ) : (
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  className="h-5 w-5"
                >
                  <circle cx="12" cy="12" r="9" />
                  <path
                    d="M8.5 12.5l2.5 2.5 4.5-5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              )}
            </span>
            <span className="flex-1">{t.message}</span>
            <button
              onClick={() => remove(t.id)}
              className="shrink-0 opacity-60 hover:opacity-100"
              aria-label="Fechar"
            >
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                className="h-4 w-4"
              >
                <path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />
              </svg>
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export const useToast = () => useContext(ToastContext);
