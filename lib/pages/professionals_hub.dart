import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/professional_type.dart';
import 'package:shape_up_app/enums/professionalManagementService/service_plan_type.dart';
import 'package:shape_up_app/enums/professionalManagementService/subscription_status.dart';
import 'package:shape_up_app/pages/chat_conversation.dart';
import 'package:shape_up_app/pages/professional_profile.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/professionalManagementService/section_title.dart';

class Palette {
  static const bg = Color(0xFF0F1623);
  static const card = Color(0xFF111A28);
  static const sheet = Color(0xFF101827);
  static const text = Color(0xFFE8EEF6);
  static const muted = Color(0xFF9AA8BD);
  static const primary = Color(0xFF2DA6FF);
  static const primaryPress = Color(0xFF1B7FD1);
  static const danger = Color(0xFFFF5A5F);
  static const dangerPress = Color(0xFFD94A4E);
  static const field = Color(0xFF0C131F);
  static const border = Color(0xFF2A3446);
  static const accent1 = Color(0xFF0C1827);
  static const accent2 = Color(0xFF13304B);

  static BoxDecoration cardDecoration({double radius = 14}) => BoxDecoration(
    color: card,
    border: Border.all(color: border),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 22, offset: Offset(0, 8))],
  );

  static OutlineInputBorder fieldBorder([double r = 12]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(r),
    borderSide: const BorderSide(color: border),
  );
}

class ProfessionalsHub extends StatefulWidget {
  @override
  _ProfessionalsHubState createState() => _ProfessionalsHubState();
}

class _ProfessionalsHubState extends State<ProfessionalsHub> {
  String selectedStatus = 'Sem Filtro';
  ClientDto? clientData;
  ProfessionalDto? professionalData;
  List<ClientDto> professionalClients = [];
  List<ProfessionalDto> recommendedProfessionals = [];
  List<ProfessionalScoreDto> recommendedProfessionalsScore = [];
  bool isLoading = true;
  bool isLoadingRecommended = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadClientData();
    _loadRecommendedProfessionals();
  }

  List<ClientDto> _filterClientsByStatus() {
    final base = professionalClients.where((c) {
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q);
    }).toList();

    if (selectedStatus == 'Sem Filtro') return base;

    return base.where((client) {
      return client.servicePlans.any((plan) {
        switch (selectedStatus) {
          case 'Ativo':
            return plan.status == SubscriptionStatus.Active;
          case 'Cancelado':
            return plan.status == SubscriptionStatus.Cancelled;
          case 'Expirado':
            return plan.status == SubscriptionStatus.Expired;
          default:
            return false;
        }
      });
    }).toList();
  }

  Future<void> _loadRecommendedProfessionals() async {
    try {
      final professionals = await ProfessionalManagementService.getProfessionalsAsync();
      final List<ProfessionalScoreDto> professionalsScore = professionals.isNotEmpty
          ? await Future.wait(
        professionals.map((professional) async {
          return await ProfessionalManagementService.getProfessionalScoreByIdAsync(professional.id);
        }),
      )
          : [];

      setState(() {
        recommendedProfessionals = professionals;
        recommendedProfessionalsScore = professionalsScore;
        isLoadingRecommended = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRecommended = false;
      });
      debugPrint('Error loading recommended professionals: $e');
    }
  }

  Future<void> _loadClientData() async {
    try {
      final profileId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(profileId);

      ProfessionalDto? professional;
      List<ClientDto> clients = [];

      if (client.isNutritionist || client.isTrainer) {
        professional = await ProfessionalManagementService.getProfessionalByIdAsync(client.id);
        clients = await ProfessionalManagementService.getProfessionalClientsAsync(professional.id);
      }

      setState(() {
        clientData = client;
        professionalData = professional;
        professionalClients = clients;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading client data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = isLoading || isLoadingRecommended;

    return Scaffold(
      backgroundColor: Palette.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
              color: Color(0xE60F1623), // ~ rgba(15,22,35,.9)
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                titleSpacing: 0,
                title: const Text('Profissionais', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
              ),
            ),
          ),
        ),
      ),
      body: busy
          ? const Center(child: CircularProgressIndicator(color: Palette.primary))
          : RefreshIndicator(
        color: Palette.primary,
        backgroundColor: Palette.card,
        onRefresh: () async {
          setState(() {
            isLoadingRecommended = true;
            isLoading = true;
          });
          await _loadClientData();
          await _loadRecommendedProfessionals();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _sectionHeader('Planos Ativos')),
            SliverToBoxAdapter(child: _buildActivePlansList()),
            SliverToBoxAdapter(child: _sectionHeader('Profissionais Recomendados')),
            SliverToBoxAdapter(child: _buildRecommendedProfessionalsList(context)),
            if (clientData != null && (clientData!.isTrainer || clientData!.isNutritionist))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildProfessionalClientsAndServices(),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  // =============== UI Pieces (estilo do HTML) ===============

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Stack(
        children: [
          TextField(
            style: const TextStyle(color: Palette.text),
            decoration: InputDecoration(
              hintText: 'Buscar profissionais...',
              hintStyle: const TextStyle(color: Palette.muted),
              filled: true,
              fillColor: Palette.field,
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: Palette.fieldBorder(12),
              enabledBorder: Palette.fieldBorder(12),
              focusedBorder: Palette.fieldBorder(12),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {List<Widget> actions = const []}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Palette.text, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          ...actions,
        ],
      ),
    );
  }

  Widget _ghostIconButton(IconData icon, {VoidCallback? onTap, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Palette.field,
            border: Border.all(color: Palette.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Palette.border),
        color: Colors.transparent,
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Palette.muted, fontWeight: FontWeight.w600)),
    );
  }

  Widget _meta(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.accent1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.accent2),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFFCFE2FF))),
    );
  }

  Widget _emptyCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.border, style: BorderStyle.solid, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Text(text, style: const TextStyle(color: Palette.muted, fontSize: 15)),
      ),
    );
  }

  // =============== Seções ===============

  Widget _buildProfessionalClientsAndServices() {
    final filteredClients = _filterClientsByStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Serviços Oferecidos',
          actions: [
            _ghostIconButton(Icons.add, tooltip: 'Adicionar serviço', onTap: _showCreateServicePlanSheet),
          ],
        ),
        if (professionalData == null || professionalData!.servicePlans.isEmpty)
          _emptyCard('Nenhum serviço oferecido no momento.')
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: professionalData!.servicePlans.map((service) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: Palette.cardDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Palette.text)),
                                  const SizedBox(height: 4),
                                  _chip('Tipo: ${service.type == ServicePlanType.Training ? 'Treino' : 'Dieta'}'),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _ghostIconButton(Icons.edit, tooltip: 'Editar', onTap: () {
                                  _showEditServiceSheet(
                                    service.id,
                                    service.title,
                                    service.description,
                                    service.durationInDays,
                                    service.price,
                                    service.type,
                                  );
                                }),
                                const SizedBox(width: 6),
                                _ghostIconButton(Icons.delete, tooltip: 'Excluir', onTap: () async {
                                  await _deleteService(service.id);
                                }),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Descrição: ${service.description}', style: const TextStyle(color: Palette.muted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _meta('Duração: ${service.durationInDays} dias'),
                            _meta('Preço: R\$ ${service.price.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        _sectionHeader(
          'Clientes',
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Palette.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedStatus,
                underline: const SizedBox.shrink(),
                dropdownColor: Palette.card,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(color: Palette.primary, fontWeight: FontWeight.w600),
                items: const ['Sem Filtro', 'Ativo', 'Cancelado', 'Expirado']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => selectedStatus = v!),
              ),
            ),
          ],
        ),
        if (filteredClients.isEmpty)
          _emptyCard('Nenhum cliente encontrado.')
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: filteredClients.map((client) {
                return _clientTile(client);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _clientTile(ClientDto client) {
    return _ExpandableCard(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(client.name, style: const TextStyle(color: Palette.text, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('E-mail: ${client.email}', style: const TextStyle(color: Palette.muted)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...client.servicePlans.map((plan) {
            final typeText = plan.servicePlan.type == ServicePlanType.Training ? 'Treino' : 'Dieta';
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border.all(color: Palette.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.servicePlan.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Palette.text)),
                  const SizedBox(height: 6),
                  Text(
                    'Período: ${DateFormat('dd/MM/yyyy').format(plan.startDate)} - ${DateFormat('dd/MM/yyyy').format(plan.endDate)}',
                    style: const TextStyle(color: Palette.muted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Status: ', style: TextStyle(color: Palette.muted)),
                      Text(_getStatusText(plan.status), style: const TextStyle(fontWeight: FontWeight.w700, color: Palette.text)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(typeText, style: const TextStyle(color: Palette.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (plan.status != SubscriptionStatus.Active) {
                            await _reactivateClientServicePlan(client.id, plan.servicePlan.id);
                          } else {
                            await _cancelClientServicePlan(client.id, plan.servicePlan.id);
                          }
                        },
                        child: Text(plan.status != SubscriptionStatus.Active ? 'Ativar' : 'Desativar', style: TextStyle(color: plan.status != SubscriptionStatus.Active ? Colors.blue : Colors.red),),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 44),
                shape: const StadiumBorder(),
              ),
              onPressed: () async {
                final profile = await SocialService.viewProfileSimplifiedAsync(client.id);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatConversation(
                      profileId: client.id,
                      profileName: client.name,
                      profileImageUrl: profile.imageUrl,
                      isProfessionalChat: true,
                    ),
                  ),
                );
              },
              child: const Text('Mensagem', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlansList() {
    if (clientData == null || clientData!.servicePlans.isEmpty) {
      return _emptyCard('Nenhum plano está ativo no momento.');
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: clientData!.servicePlans.map((plan) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: Palette.cardDecoration(),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              title: Text(plan.servicePlan.title, style: const TextStyle(color: Palette.text, fontWeight: FontWeight.w700)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${dateFormat.format(plan.startDate)} até ${dateFormat.format(plan.endDate)}\n'
                      'Status: ${_getStatusText(plan.status)}\n'
                      '${plan.servicePlan.type == ServicePlanType.Training ? 'Treino' : 'Dieta'}',
                  style: const TextStyle(color: Palette.muted, height: 1.35),
                ),
              ),
              trailing: _moreMenu(
                onSelected: (value) async {
                  switch (value) {
                    case 'reactivate':
                      if (plan.status != SubscriptionStatus.Active) {
                        _reactivateClientServicePlan(clientData!.id, plan.servicePlan.id);
                      } else {
                        _cancelClientServicePlan(clientData!.id, plan.servicePlan.id);
                      }
                      break;
                    case 'review':
                      _showReviewSheet(plan.servicePlan.professionalId, plan.servicePlan.id);
                      break;
                    case 'viewProfile':
                      ProfessionalDto professional = await ProfessionalManagementService.getProfessionalByIdAsync(plan.servicePlan.professionalId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfessionalProfile(
                            professional: professional,
                            professionalScore: recommendedProfessionalsScore.firstWhere(
                                  (score) => score.professionalId == professional.id,
                              orElse: () => ProfessionalScoreDto('', 0, 0, DateTime.now()),
                            ),
                            loggedInUser: clientData!,
                          ),
                        ),
                      );
                      break;
                  }
                },
                active: plan.status == SubscriptionStatus.Active,
                isActiveNow: plan.status == SubscriptionStatus.Active,
              ),
              enabled: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _moreMenu({required void Function(String) onSelected, required bool active, required bool isActiveNow}) {
    return PopupMenuButton<String>(
      color: Palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Palette.border)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'reactivate',
          child: Text(isActiveNow ? 'Cancelar' : 'Reativar', style: const TextStyle(color: Palette.text)),
        ),
        const PopupMenuItem(
          value: 'review',
          child: Text('Avaliar', style: TextStyle(color: Palette.text)),
        ),
        const PopupMenuItem(
          value: 'viewProfile',
          child: Text('Ver perfil do profissional', style: TextStyle(color: Palette.text)),
        ),
      ],
      icon: const Icon(Icons.more_vert, color: Colors.white70),
    );
  }

  Widget _buildRecommendedProfessionalsList(BuildContext context) {
    if (recommendedProfessionals.isEmpty) {
      return _emptyCard('Nenhum profissional recomendado no momento.');
    }

    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: recommendedProfessionals.map((professional) {
          final score = recommendedProfessionalsScore.firstWhere(
                (s) => s.professionalId == professional.id,
            orElse: () => ProfessionalScoreDto('', 0, 0, DateTime.now()),
          );
          return Container(
            width: 220,
            margin: const EdgeInsets.all(8),
            decoration: Palette.cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(professional.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Palette.text)),
                  const SizedBox(height: 4),
                  Text(
                    switch (professional.type) {
                      ProfessionalType.Nutritionist => 'Nutricionista',
                      ProfessionalType.Trainer => 'Personal Trainer',
                      ProfessionalType.Both => 'Nutricionista e Personal Trainer',
                    },
                    style: const TextStyle(color: Palette.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(score.averageScore.toStringAsFixed(1), style: const TextStyle(color: Palette.text)),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfessionalProfile(
                            professional: professional,
                            professionalScore: score,
                            loggedInUser: clientData!,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver Perfil'),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =============== Helpers de status/ações ===============

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.Active:
        return 'Ativo';
      case SubscriptionStatus.Cancelled:
        return 'Cancelado';
      case SubscriptionStatus.Expired:
        return 'Expirado';
    }
  }

  Future<void> _reactivateClientServicePlan(String clientId, String servicePlanId) async {
    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Palette.sheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: Palette.border),
        ),
        isScrollControlled: true,
        builder: (_) {
          return _ConfirmSheet(
            title: 'Reativar Plano de Serviço',
            message: 'Você tem certeza que deseja reativar este plano de serviço?',
            confirmText: 'Reativar',
            onConfirm: () async {
              await ProfessionalManagementService.activateServicePlanToClientAsync(clientId, servicePlanId);
              await _loadClientData();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plano de serviço reativado com sucesso!')));
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Erro ao reativar plano de serviço: $e');
    }
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Palette.sheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: Palette.border),
        ),
        builder: (_) {
          return _ConfirmSheet(
            title: 'Confirmar Exclusão',
            message: 'Tem certeza que deseja excluir este serviço?',
            confirmText: 'Excluir',
            isDanger: true,
            onConfirm: () async {
              await ProfessionalManagementService.deleteServicePlanByIdAsync(serviceId);
              await _loadClientData();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço excluído com sucesso!')));
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Erro ao excluir serviço: $e');
    }
  }

  Future<void> _cancelClientServicePlan(String clientId, String servicePlanId) async {
    final reasonController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Palette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Palette.border),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _SheetScaffold(
            title: 'Desativar Plano de Serviço',
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Por favor, insira a razão para o cancelamento:', style: TextStyle(color: Palette.muted)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: const TextStyle(color: Palette.text),
                  decoration: InputDecoration(
                    labelText: 'Razão',
                    labelStyle: const TextStyle(color: Palette.muted),
                    filled: true,
                    fillColor: Palette.field,
                    border: Palette.fieldBorder(10),
                    enabledBorder: Palette.fieldBorder(10),
                    focusedBorder: Palette.fieldBorder(10),
                  ),
                ),
              ],
            ),
            actions: [
              _ghostButton('Cancelar', onTap: () => Navigator.of(context).pop()),
              _filledButton('Confirmar', onTap: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A razão do cancelamento é obrigatória!')));
                  return;
                }
                try {
                  await ProfessionalManagementService.deactivateServicePlanFromClientAsync(
                    clientId,
                    servicePlanId,
                    reasonController.text,
                  );
                  await _loadClientData();
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plano de serviço cancelado com sucesso!')));
                  }
                } catch (e) {
                  debugPrint('Erro ao cancelar plano de serviço: $e');
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // =============== Sheets (Criar/Editar/Avaliar) ===============

  void _showEditServiceSheet(String servicePlanId, String currentTitle, String currentDescription, int currentDuration,
      double currentPrice, ServicePlanType currentType) {
    _openServiceSheet(
      mode: _ServiceSheetMode.edit,
      initial: _ServiceData(
        title: currentTitle,
        desc: currentDescription,
        duration: currentDuration.toString(),
        price: currentPrice.toStringAsFixed(2),
        type: currentType,
      ),
      onSubmit: (data) async {
        final int? dur = int.tryParse(data.duration);
        final double? price = double.tryParse(data.price.replaceAll(',', '.'));
        await ProfessionalManagementService.updateServicePlanByIdAsync(
          servicePlanId,
          data.title.isNotEmpty ? data.title : null,
          data.desc.isNotEmpty ? data.desc : null,
          dur,
          price,
          data.type,
        );
        await _loadClientData();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço atualizado com sucesso!')));
        }
      },
    );
  }

  void _showCreateServicePlanSheet() {
    _openServiceSheet(
      mode: _ServiceSheetMode.create,
      onSubmit: (data) async {
        final int? duration = int.tryParse(data.duration);
        final double? price = double.tryParse(data.price.replaceAll(',', '.'));

        if (data.title.isNotEmpty && data.desc.isNotEmpty && duration != null && price != null) {
          await ProfessionalManagementService.createServicePlanAsync(
            data.title,
            data.desc,
            duration,
            price,
            data.type,
          );
          await _loadClientData();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço criado com sucesso!')));
          }
        }
      },
    );
  }

  void _showReviewSheet(String professionalId, String servicePlanId) {
    final commentController = TextEditingController();
    int updatedRating = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Palette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Palette.border),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _SheetScaffold(
            title: 'Avaliar profissional',
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Nota:', style: TextStyle(color: Palette.text)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Palette.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<int>(
                        value: updatedRating,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Palette.card,
                        borderRadius: BorderRadius.circular(12),
                        style: const TextStyle(color: Palette.text),
                        items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                        onChanged: (v) => setState(() => updatedRating = v ?? 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: const TextStyle(color: Palette.text),
                  decoration: InputDecoration(
                    labelText: 'Comentário',
                    labelStyle: const TextStyle(color: Palette.muted),
                    filled: true,
                    fillColor: Palette.field,
                    border: Palette.fieldBorder(10),
                    enabledBorder: Palette.fieldBorder(10),
                    focusedBorder: Palette.fieldBorder(10),
                  ),
                ),
              ],
            ),
            actions: [
              _ghostButton('Cancelar', onTap: () => Navigator.of(context).pop()),
              _filledButton('Salvar', onTap: () async {
                try {
                  await ProfessionalManagementService.createProfessionalReviewAsync(
                    professionalId,
                    servicePlanId,
                    commentController.text,
                    updatedRating,
                  );
                  await _loadRecommendedProfessionals();
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profissional avaliado com sucesso!')));
                  }
                } catch (e) {
                  debugPrint('Erro ao avaliar professional: $e');
                }
              }),
            ],
          ),
        );
      },
    );
  }

  void _openServiceSheet({
    required _ServiceSheetMode mode,
    _ServiceData? initial,
    required Future<void> Function(_ServiceData) onSubmit,
  }) {
    final titleController = TextEditingController(text: initial?.title ?? '');
    final descController = TextEditingController(text: initial?.desc ?? '');
    final durController = TextEditingController(text: initial?.duration ?? '');
    final priceController = TextEditingController(text: initial?.price ?? '');
    ServicePlanType selectedType = initial?.type ?? ServicePlanType.Training;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Palette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Palette.border),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _SheetScaffold(
            title: mode == _ServiceSheetMode.edit ? 'Editar Serviço' : 'Criar Novo Serviço',
            child: Column(
              children: [
                _fieldGroup(
                  label: 'Título',
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(color: Palette.text),
                    decoration: InputDecoration(
                      hintText: 'Ex.: Dieta Premium',
                      hintStyle: const TextStyle(color: Palette.muted),
                      filled: true, fillColor: Palette.field,
                      border: Palette.fieldBorder(10),
                      enabledBorder: Palette.fieldBorder(10),
                      focusedBorder: Palette.fieldBorder(10),
                    ),
                  ),
                ),
                _fieldGroup(
                  label: 'Descrição',
                  child: TextField(
                    controller: descController,
                    maxLines: 3,
                    style: const TextStyle(color: Palette.text),
                    decoration: InputDecoration(
                      hintText: 'Conte brevemente o que inclui',
                      hintStyle: const TextStyle(color: Palette.muted),
                      filled: true, fillColor: Palette.field,
                      border: Palette.fieldBorder(10),
                      enabledBorder: Palette.fieldBorder(10),
                      focusedBorder: Palette.fieldBorder(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _fieldGroup(
                        label: 'Duração (em dias)',
                        child: TextField(
                          controller: durController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Palette.text),
                          decoration: InputDecoration(
                            hintText: '30',
                            hintStyle: const TextStyle(color: Palette.muted),
                            filled: true, fillColor: Palette.field,
                            border: Palette.fieldBorder(10),
                            enabledBorder: Palette.fieldBorder(10),
                            focusedBorder: Palette.fieldBorder(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _fieldGroup(
                        label: 'Preço',
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Palette.text),
                          decoration: InputDecoration(
                            hintText: '39,90',
                            hintStyle: const TextStyle(color: Palette.muted),
                            filled: true, fillColor: Palette.field,
                            border: Palette.fieldBorder(10),
                            enabledBorder: Palette.fieldBorder(10),
                            focusedBorder: Palette.fieldBorder(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _fieldGroup(
                  label: 'Tipo',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Palette.field,
                      border: Border.all(color: Palette.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<ServicePlanType>(
                      value: selectedType,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: Palette.card,
                      style: const TextStyle(color: Palette.text),
                      items: ServicePlanType.values.map((type) {
                        final label = type == ServicePlanType.Training ? 'Treino' : 'Dieta';
                        return DropdownMenuItem(value: type, child: Text(label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedType = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              _ghostButton('Cancelar', onTap: () => Navigator.of(context).pop()),
              _filledButton('Salvar', onTap: () async {
                final data = _ServiceData(
                  title: titleController.text.trim(),
                  desc: descController.text.trim(),
                  duration: durController.text.trim(),
                  price: priceController.text.trim(),
                  type: selectedType,
                );
                await onSubmit(data);
              }),
            ],
          ),
        );
      },
    );
  }

  // =============== Mini-widgets dos sheets ===============

  Widget _fieldGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Palette.muted, fontSize: 13)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _ghostButton(String text, {VoidCallback? onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Palette.border),
        foregroundColor: Palette.text,
        backgroundColor: Colors.transparent,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _filledButton(String text, {VoidCallback? onTap, bool danger = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? Palette.danger : Palette.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

// ======= Widgets de apoio =======

class _ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget body;
  const _ExpandableCard({required this.title, required this.body});

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: Palette.cardDecoration(),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => open = !open),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  AnimatedRotation(
                    turns: open ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: widget.body),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final bool isDanger;
  final Future<void> Function() onConfirm;

  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: title,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(message, style: const TextStyle(color: Palette.text)),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Palette.border),
            foregroundColor: Palette.text,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? Palette.danger : Palette.primary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const _SheetScaffold({required this.title, required this.child, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Palette.text))),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            child,
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ...actions.map((w) => Padding(padding: const EdgeInsets.only(left: 8), child: w)),
            ]),
          ],
        ),
      ),
    );
  }
}

enum _ServiceSheetMode { create, edit }

class _ServiceData {
  final String title;
  final String desc;
  final String duration;
  final String price;
  final ServicePlanType type;

  _ServiceData({
    required this.title,
    required this.desc,
    required this.duration,
    required this.price,
    required this.type,
  });
}
