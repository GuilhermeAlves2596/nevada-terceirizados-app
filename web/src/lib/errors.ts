// Traduz erros de escrita (Firestore rules e Cloud Functions) em mensagens
// amigáveis. Usado com os toasts de erro nas telas de CRUD.

type MaybeFirebaseError = {
  code?: string;
  message?: string;
};

/**
 * Mensagem amigável para uma falha de operação.
 * - Erros de Cloud Function (code "functions/...") já vêm com message em PT
 *   (definida nas HttpsError), então usamos essa message.
 * - `permission-denied` do Firestore é escrita bloqueada pelas rules: se a
 *   assinatura da empresa está inativa (opts.subscriptionInactive), esse é o
 *   motivo mais provável; senão, é falta de permissão.
 */
export function errorMessage(
  err: unknown,
  opts?: { subscriptionInactive?: boolean; fallback?: string },
): string {
  const e = err as MaybeFirebaseError;
  const code = e?.code;

  if (typeof code === "string" && code.startsWith("functions/")) {
    return e.message || "Não foi possível concluir a ação.";
  }

  if (code === "permission-denied") {
    return opts?.subscriptionInactive
      ? "A assinatura da empresa está inativa. Regularize a assinatura para " +
          "fazer alterações."
      : "Sem permissão para esta ação.";
  }

  return opts?.fallback ?? "Não foi possível concluir a ação. Tente novamente.";
}
