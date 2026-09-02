import { doc, setDoc } from 'firebase/firestore';

/// Coleções com escopo de empresa (todas carregam companyId).
export const COLLECTIONS = [
  'clients',
  'contracts',
  'locations',
  'checklists',
  'tasks',
  'taskExecutions',
];

/// Popula a base de teste (chamado dentro de withSecurityRulesDisabled).
///
/// 3 empresas (A e B ativas; SUSP suspensa) e usuários de cada papel, mais um
/// doc por coleção em cada empresa para os testes de isolamento.
export async function seedBaseline(db) {
  const now = new Date();
  const base = { createdAt: now, updatedAt: now };

  await setDoc(doc(db, 'companies/company_a'), { name: 'A', subscriptionStatus: 'active', active: true, ...base });
  await setDoc(doc(db, 'companies/company_b'), { name: 'B', subscriptionStatus: 'active', active: true, ...base });
  await setDoc(doc(db, 'companies/company_susp'), { name: 'S', subscriptionStatus: 'suspended', active: true, ...base });

  await setDoc(doc(db, 'users/plat'), { name: 'Plat', role: 'platformAdmin', companyId: null, active: true, ...base });
  await setDoc(doc(db, 'users/admin_a'), { name: 'Admin A', role: 'companyAdmin', companyId: 'company_a', active: true, ...base });
  await setDoc(doc(db, 'users/sup_a'), { name: 'Sup A', role: 'supervisor', companyId: 'company_a', active: true, ...base });
  await setDoc(doc(db, 'users/emp_a'), { name: 'Emp A', role: 'employee', companyId: 'company_a', active: true, ...base });
  await setDoc(doc(db, 'users/sup_b'), { name: 'Sup B', role: 'supervisor', companyId: 'company_b', active: true, ...base });
  await setDoc(doc(db, 'users/sup_susp'), { name: 'Sup S', role: 'supervisor', companyId: 'company_susp', active: true, ...base });

  for (const col of COLLECTIONS) {
    await setDoc(doc(db, `${col}/${col}_a`), { companyId: 'company_a', name: 'x', ...base });
    await setDoc(doc(db, `${col}/${col}_b`), { companyId: 'company_b', name: 'y', ...base });
  }
  await setDoc(doc(db, 'clients/clients_susp'), { companyId: 'company_susp', name: 's', ...base });
}
