import '../../features/auth/domain/entities/app_user.dart';
import '../../features/checklists/domain/entities/checklist.dart';
import '../../features/checklists/domain/entities/checklist_item.dart';
import '../../features/clients/domain/entities/client.dart';
import '../../features/companies/domain/entities/company.dart';
import '../../features/contracts/domain/entities/contract.dart';
import '../../features/executions/domain/entities/task_execution.dart';
import '../../features/locations/domain/entities/location.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../enums/contract_status.dart';
import '../enums/service_type.dart';
import '../enums/subscription_status.dart';
import '../enums/task_priority.dart';
import '../enums/task_status.dart';
import '../enums/user_role.dart';

/// Banco de dados em memória usado como fonte de dados mockada (Fases 1–7).
///
/// Centraliza o "seed" para que todos os repositórios mock leiam de uma única
/// fonte coerente. Quando entrarmos no Firestore, cada repositório troca esta
/// fonte pela implementação Firebase — sem mexer em domínio/apresentação.
class MockDatabase {
  MockDatabase._({
    required this.companies,
    required this.users,
    required this.clients,
    required this.contracts,
    required this.locations,
    required this.checklists,
    required this.tasks,
    required this.executions,
  });

  final List<Company> companies;
  final List<AppUser> users;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<Location> locations;
  final List<Checklist> checklists;
  final List<Task> tasks;

  /// Execuções criadas sob demanda quando o funcionário abre uma tarefa.
  final List<TaskExecution> executions;

  // ---- Identificadores fixos (facilitam o cruzamento entre entidades) ----
  static const companyNevada = 'company_nevada';

  static const userGestora = 'user_gestora'; // companyAdmin (gestor da empresa)
  static const userCarlos = 'user_carlos'; // supervisor
  static const userJoao = 'user_joao';
  static const userMaria = 'user_maria';
  static const userPedro = 'user_pedro';

  static const clientPrefeitura = 'client_prefeitura';
  static const clientAbc = 'client_abc';
  static const clientCondominio = 'client_condominio';

  static const contractLimpeza2026 = 'contract_limpeza_2026';

  static const locPredio = 'loc_predio_adm';
  static const locBlocoA = 'loc_bloco_a';
  static const locBanheiroA = 'loc_banheiro_bloco_a';
  static const locRecepcao = 'loc_recepcao';
  static const locBanheiroAdm = 'loc_banheiro_adm';
  static const locAreaExterna = 'loc_area_externa';

  static const chkBanheiro = 'chk_banheiro';
  static const chkRecepcao = 'chk_recepcao';
  static const chkJardim = 'chk_jardim';
  static const chkEscritorio = 'chk_escritorio';

  /// Constrói a base completa de demonstração.
  factory MockDatabase.seeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime daysAgo(int d) => today.subtract(Duration(days: d));
    DateTime daysAhead(int d) => today.add(Duration(days: d));

    final createdBase = daysAgo(40);

    final company = Company(
      id: companyNevada,
      name: 'Nevada Serviços Terceirizados',
      document: '12.345.678/0001-90',
      plan: 'pro',
      subscriptionStatus: SubscriptionStatus.active,
      seats: 20,
      createdAt: createdBase,
      updatedAt: createdBase,
    );

    // Vínculos provisórios (definidos via seed até o painel web do gestor
    // existir): supervisor e funcionários operam no mesmo cliente/contrato.
    const seedContractIds = <String>[contractLimpeza2026];
    const seedClientIds = <String>[clientPrefeitura];

    final users = <AppUser>[
      // Gestor da empresa (companyAdmin) — provisionado por seed. Sem vínculo
      // a cliente/contrato: enxerga todo o escopo da Nevada.
      AppUser(
        id: userGestora,
        companyId: companyNevada,
        name: 'Renata Gestora',
        email: 'gestor@teste.com',
        role: UserRole.companyAdmin,
        phone: '(11) 98888-0001',
        jobTitle: 'Gestora de Contratos',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      AppUser(
        id: userCarlos,
        companyId: companyNevada,
        name: 'Carlos Oliveira',
        email: 'supervisor@teste.com',
        role: UserRole.supervisor,
        contractIds: seedContractIds,
        clientIds: seedClientIds,
        phone: '(11) 98888-1000',
        jobTitle: 'Supervisor de Operações',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      AppUser(
        id: userJoao,
        companyId: companyNevada,
        name: 'João Silva',
        email: 'funcionario@teste.com',
        role: UserRole.employee,
        contractIds: seedContractIds,
        clientIds: seedClientIds,
        phone: '(11) 97777-2001',
        jobTitle: 'Auxiliar de Limpeza',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      AppUser(
        id: userMaria,
        companyId: companyNevada,
        name: 'Maria Santos',
        email: 'maria@teste.com',
        role: UserRole.employee,
        contractIds: seedContractIds,
        clientIds: seedClientIds,
        phone: '(11) 97777-2002',
        jobTitle: 'Auxiliar de Limpeza',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      AppUser(
        id: userPedro,
        companyId: companyNevada,
        name: 'Pedro Almeida',
        email: 'pedro@teste.com',
        role: UserRole.employee,
        contractIds: seedContractIds,
        clientIds: seedClientIds,
        phone: '(11) 97777-2003',
        jobTitle: 'Jardineiro',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
    ];

    final clients = <Client>[
      Client(
        id: clientPrefeitura,
        companyId: companyNevada,
        name: 'Prefeitura Municipal',
        document: '11.111.111/0001-11',
        phone: '(11) 3000-0000',
        email: 'contato@prefeitura.gov.br',
        address: 'Praça da Matriz, 1 - Centro',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Client(
        id: clientAbc,
        companyId: companyNevada,
        name: 'Empresa ABC',
        document: '22.222.222/0001-22',
        phone: '(11) 3111-1111',
        address: 'Av. Industrial, 500',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Client(
        id: clientCondominio,
        companyId: companyNevada,
        name: 'Condomínio Central',
        document: '33.333.333/0001-33',
        phone: '(11) 3222-2222',
        address: 'Rua das Palmeiras, 200',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
    ];

    final contracts = <Contract>[
      Contract(
        id: contractLimpeza2026,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        name: 'Contrato de Limpeza 2026',
        description: 'Serviços de limpeza e conservação predial.',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        status: ContractStatus.active,
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
    ];

    final locations = <Location>[
      Location(
        id: locPredio,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Prédio Administrativo',
        description: 'Sede administrativa da prefeitura.',
        address: 'Praça da Matriz, 1 - Centro',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Location(
        id: locBlocoA,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Bloco A',
        parentLocationId: locPredio,
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Location(
        id: locBanheiroA,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Banheiro Bloco A',
        parentLocationId: locBlocoA,
        qrCodeId: 'QR-NVD-0001',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Location(
        id: locRecepcao,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Recepção',
        parentLocationId: locPredio,
        qrCodeId: 'QR-NVD-0002',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Location(
        id: locBanheiroAdm,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Banheiro Administrativo',
        parentLocationId: locPredio,
        qrCodeId: 'QR-NVD-0003',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Location(
        id: locAreaExterna,
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        name: 'Área Externa',
        parentLocationId: locPredio,
        qrCodeId: 'QR-NVD-0004',
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
    ];

    ChecklistItem item(int order, String desc, {bool required = true}) =>
        ChecklistItem(
          id: 'ci_${order}_${desc.hashCode}',
          description: desc,
          order: order,
          required: required,
        );

    final checklists = <Checklist>[
      Checklist(
        id: chkBanheiro,
        companyId: companyNevada,
        name: 'Limpeza de Banheiro',
        serviceType: ServiceType.limpeza,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        items: [
          item(1, 'Varrer o piso'),
          item(2, 'Lavar o piso'),
          item(3, 'Limpar vasos sanitários'),
          item(4, 'Limpar pias'),
          item(5, 'Limpar espelhos'),
          item(6, 'Repor papel higiênico'),
          item(7, 'Repor sabonete'),
          item(8, 'Retirar lixo'),
        ],
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Checklist(
        id: chkRecepcao,
        companyId: companyNevada,
        name: 'Limpeza de Recepção',
        serviceType: ServiceType.limpeza,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        items: [
          item(1, 'Limpar balcão de atendimento'),
          item(2, 'Aspirar tapetes'),
          item(3, 'Limpar vidros e portas'),
          item(4, 'Organizar folhetos'),
          item(5, 'Retirar lixo'),
        ],
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Checklist(
        id: chkJardim,
        companyId: companyNevada,
        name: 'Manutenção de Jardim',
        serviceType: ServiceType.jardinagem,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        items: [
          item(1, 'Aparar a grama'),
          item(2, 'Podar arbustos'),
          item(3, 'Regar as plantas'),
          item(4, 'Recolher folhas'),
        ],
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
      Checklist(
        id: chkEscritorio,
        companyId: companyNevada,
        name: 'Higienização de Escritório',
        serviceType: ServiceType.higienizacao,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        items: [
          item(1, 'Limpar mesas e superfícies'),
          item(2, 'Higienizar maçanetas'),
          item(3, 'Limpar teclados e telefones'),
          item(4, 'Esvaziar lixeiras'),
          item(5, 'Passar pano no chão'),
        ],
        createdAt: createdBase,
        updatedAt: createdBase,
      ),
    ];

    var taskSeq = 0;
    Task task({
      required String location,
      required String checklist,
      required String assignedTo,
      required DateTime date,
      required TaskStatus status,
      required int progress,
      TaskPriority priority = TaskPriority.normal,
      String? startTime,
    }) {
      taskSeq++;
      return Task(
        id: 'task_${taskSeq.toString().padLeft(3, '0')}',
        companyId: companyNevada,
        clientId: clientPrefeitura,
        contractId: contractLimpeza2026,
        locationId: location,
        checklistId: checklist,
        assignedTo: assignedTo,
        assignedBy: userCarlos,
        scheduledDate: date,
        scheduledStartTime: startTime,
        priority: priority,
        status: status,
        progress: progress,
        createdAt: daysAgo(3),
        updatedAt: now,
      );
    }

    final tasks = <Task>[
      // João — hoje
      task(
        location: locBanheiroA,
        checklist: chkBanheiro,
        assignedTo: userJoao,
        date: today,
        status: TaskStatus.inProgress,
        progress: 75,
        priority: TaskPriority.high,
        startTime: '08:00',
      ),
      task(
        location: locRecepcao,
        checklist: chkRecepcao,
        assignedTo: userJoao,
        date: today,
        status: TaskStatus.pending,
        progress: 0,
        startTime: '10:00',
      ),
      task(
        location: locBanheiroAdm,
        checklist: chkBanheiro,
        assignedTo: userJoao,
        date: today,
        status: TaskStatus.pending,
        progress: 0,
        startTime: '13:00',
      ),
      task(
        location: locAreaExterna,
        checklist: chkJardim,
        assignedTo: userJoao,
        date: today,
        status: TaskStatus.completed,
        progress: 100,
        startTime: '07:00',
      ),
      // João — atrasada (ontem, ainda pendente)
      task(
        location: locRecepcao,
        checklist: chkRecepcao,
        assignedTo: userJoao,
        date: daysAgo(1),
        status: TaskStatus.pending,
        progress: 0,
        priority: TaskPriority.urgent,
        startTime: '15:00',
      ),
      // João — histórico concluído
      task(
        location: locBanheiroA,
        checklist: chkBanheiro,
        assignedTo: userJoao,
        date: daysAgo(1),
        status: TaskStatus.completed,
        progress: 100,
        startTime: '08:00',
      ),
      task(
        location: locBanheiroAdm,
        checklist: chkEscritorio,
        assignedTo: userJoao,
        date: daysAgo(2),
        status: TaskStatus.completed,
        progress: 100,
        startTime: '09:00',
      ),
      // Maria
      task(
        location: locRecepcao,
        checklist: chkRecepcao,
        assignedTo: userMaria,
        date: today,
        status: TaskStatus.inProgress,
        progress: 40,
        startTime: '08:30',
      ),
      task(
        location: locBanheiroAdm,
        checklist: chkBanheiro,
        assignedTo: userMaria,
        date: today,
        status: TaskStatus.pending,
        progress: 0,
        startTime: '11:00',
      ),
      task(
        location: locBlocoA,
        checklist: chkEscritorio,
        assignedTo: userMaria,
        date: daysAgo(1),
        status: TaskStatus.completed,
        progress: 100,
        startTime: '14:00',
      ),
      // Pedro (jardinagem)
      task(
        location: locAreaExterna,
        checklist: chkJardim,
        assignedTo: userPedro,
        date: today,
        status: TaskStatus.pending,
        progress: 0,
        priority: TaskPriority.normal,
        startTime: '07:30',
      ),
      task(
        location: locAreaExterna,
        checklist: chkJardim,
        assignedTo: userPedro,
        date: daysAhead(1),
        status: TaskStatus.pending,
        progress: 0,
        startTime: '07:30',
      ),
    ];

    return MockDatabase._(
      companies: [company],
      users: users,
      clients: clients,
      contracts: contracts,
      locations: locations,
      checklists: checklists,
      tasks: tasks,
      executions: [],
    );
  }

  /// Substitui uma tarefa pela versão atualizada (usado pelos mocks ao refletir
  /// mudanças de execução no status/progresso da tarefa).
  void upsertTask(Task task) {
    final i = tasks.indexWhere((t) => t.id == task.id);
    if (i >= 0) {
      tasks[i] = task;
    } else {
      tasks.add(task);
    }
  }

  /// Insere ou atualiza uma execução.
  void upsertExecution(TaskExecution execution) {
    final i = executions.indexWhere((e) => e.id == execution.id);
    if (i >= 0) {
      executions[i] = execution;
    } else {
      executions.add(execution);
    }
  }

  void upsertUser(AppUser user) {
    final i = users.indexWhere((u) => u.id == user.id);
    if (i >= 0) {
      users[i] = user;
    } else {
      users.add(user);
    }
  }

  void upsertClient(Client client) {
    final i = clients.indexWhere((c) => c.id == client.id);
    if (i >= 0) {
      clients[i] = client;
    } else {
      clients.add(client);
    }
  }

  void upsertContract(Contract contract) {
    final i = contracts.indexWhere((c) => c.id == contract.id);
    if (i >= 0) {
      contracts[i] = contract;
    } else {
      contracts.add(contract);
    }
  }

  void upsertLocation(Location location) {
    final i = locations.indexWhere((l) => l.id == location.id);
    if (i >= 0) {
      locations[i] = location;
    } else {
      locations.add(location);
    }
  }

  void upsertChecklist(Checklist checklist) {
    final i = checklists.indexWhere((c) => c.id == checklist.id);
    if (i >= 0) {
      checklists[i] = checklist;
    } else {
      checklists.add(checklist);
    }
  }
}
