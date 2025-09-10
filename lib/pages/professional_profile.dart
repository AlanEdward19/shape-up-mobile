import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/service_plan_dto.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/service_plan_type.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/social_service.dart';

import 'chat_conversation.dart';

/// Paleta azul (ajustada)
class _AppColors {
  static const bg = Color(0xFF0E1420);
  static const surface = Color(0xFF102035);     // azul escuro
  static const card = Color(0xFF0F1B2E);        // card azul, nada de preto
  static const sheet = Color(0xFF10223A);       // fundo de diálogos
  static const text = Color(0xFFE9EEF7);
  static const muted = Color(0xFFAEC3E0);
  static const primary = Color(0xFF3B82F6);     // azul principal
  static const primaryPress = Color(0xFF2563EB);
  static const success = Color(0xFF29CC7A);
  static const successInk = Color(0xFF0F2A1D);
  static const danger = Color(0xFFFF5A5F);
  static const field = Color(0xFF0B1220);
  static const border = Color(0xFF244061);      // borda azul
  static const amber = Color(0xFFFFD24A);
}

class ProfessionalProfile extends StatefulWidget {
  final ProfessionalDto professional;
  final ProfessionalScoreDto? professionalScore;
  final ClientDto loggedInUser;

  const ProfessionalProfile({
    required this.professional,
    required this.professionalScore,
    required this.loggedInUser,
    super.key,
  });

  @override
  _ProfessionalProfileState createState() => _ProfessionalProfileState();
}

class _ProfessionalProfileState extends State<ProfessionalProfile> {
  SimplifiedProfileDto? simplifiedProfile;
  List<ClientProfessionalReviewDto> reviews = [];
  bool isLoading = true;
  String loggedInUserProfileId = '';

  @override
  void initState() {
    super.initState();
    _loadProfessionalImageAndReviewList();
  }

  Future<void> _loadProfessionalImageAndReviewList() async {
    try {
      final reviewList =
      await ProfessionalManagementService.getProfessionalReviewsByIdAsync(
        widget.professional.id,
      );

      final profile = await SocialService.viewProfileSimplifiedAsync(
        widget.professional.id,
      );

      final loggedInUserId = await AuthenticationService.getProfileId();

      setState(() {
        reviews = reviewList;
        simplifiedProfile = profile;
        isLoading = false;
        loggedInUserProfileId = loggedInUserId;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading professional data: $e');
    }
  }

  Future<void> _loadProfessionalData() async {
    try {
      final updatedProfessionalScore =
      await ProfessionalManagementService.getProfessionalScoreByIdAsync(
        widget.professional.id,
      );

      final updatedProfessional =
      await ProfessionalManagementService.getProfessionalByIdAsync(
        widget.professional.id,
      );

      setState(() {
        widget.professionalScore?.averageScore =
            updatedProfessionalScore.averageScore;
        widget.professionalScore?.totalReviews =
            updatedProfessionalScore.totalReviews;
        widget.professionalScore?.lastUpdated =
            updatedProfessionalScore.lastUpdated;

        widget.professional.name = updatedProfessional.name;
        widget.professional.email = updatedProfessional.email;
        widget.professional.type = updatedProfessional.type;
        widget.professional.isVerified = updatedProfessional.isVerified;
        widget.professional.servicePlans.clear();
        widget.professional.servicePlans
            .addAll(updatedProfessional.servicePlans);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading professional data: $e');
    }
  }

  Future<void> _loadClientData() async {
    try {
      final loggedInUserId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(
        loggedInUserId,
      );

      setState(() {
        widget.loggedInUser.servicePlans.clear();
        widget.loggedInUser.servicePlans.addAll(client.servicePlans);
      });
    } catch (e) {
      debugPrint('Error loading client data: $e');
    }
  }

  bool _userHasPlanWithProfessional() {
    return widget.loggedInUser.servicePlans.any(
          (sp) => sp.servicePlan.professionalId == widget.professional.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canChat = _userHasPlanWithProfessional();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _TopAppBar(
        title: widget.professional.name,
        trailing: canChat
            ? IconButton(
          tooltip: 'Mensagens',
          icon: const Icon(Icons.message, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatConversation(
                  profileId: widget.professional.id,
                  profileName: widget.professional.name,
                  profileImageUrl: simplifiedProfile?.imageUrl ?? '',
                  isProfessionalChat: true,
                ),
              ),
            );
          },
        )
            : null,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      )
          : RefreshIndicator(
        color: _AppColors.primary,
        backgroundColor: _AppColors.field,
        onRefresh: () async {
          setState(() => isLoading = true);
          await _loadClientData();
          await _loadProfessionalData();
          await _loadProfessionalImageAndReviewList();
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.04,
                        screenHeight * 0.02,
                        screenWidth * 0.04,
                        0,
                      ),
                      child: _ProfileHeader(
                        name: widget.professional.name,
                        imageUrl: simplifiedProfile?.imageUrl,
                        rating: widget.professionalScore?.averageScore,
                        totalReviews: widget.professionalScore?.totalReviews,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionTitle('Planos Disponíveis'),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    sliver: SliverList.separated(
                      itemCount: widget.professional.servicePlans.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: screenHeight * 0.01),
                      itemBuilder: (context, index) {
                        final plan = widget.professional.servicePlans[index];
                        final isHired = widget.loggedInUser.servicePlans.any(
                              (sp) => sp.servicePlan.id == plan.id,
                        );

                        return _GradientCard(
                          dim: isHired,
                          child: _PlanRow(
                            title: plan.title,
                            description: plan.description,
                            typeLabel: plan.type == ServicePlanType.Training
                                ? 'Treino'
                                : 'Dieta',
                            isHired: isHired,
                            priceLabel:
                            'R\$ ${plan.price.toStringAsFixed(2)}',
                            onTapAction: isHired
                                ? null
                                : () => _showHireServicePlanDialog(plan),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionTitle('Avaliações'),
                  ),
                  if (reviews.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Nenhuma avaliação disponível.',
                          style: TextStyle(color: _AppColors.text),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      sliver: SliverList.separated(
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: screenHeight * 0.01),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          final canEditDelete =
                              review.clientId == loggedInUserProfileId;

                          return _GradientCard(
                            child: _ReviewCard(
                              name: review.clientName,
                              rating: review.rating,
                              comment: review.comment,
                              lastUpdated: review.lastUpdatedAt,
                              canEditDelete: canEditDelete,
                              onEdit: () =>
                                  _showEditReviewDialog(review),
                              onDelete: () =>
                                  _showDeleteReviewDialog(review.id),
                            ),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======= DIALOGS =======

  void _showDeleteReviewDialog(String reviewId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ThemedAlertDialog(
          title: 'Confirmar Exclusão',
          content: 'Tem certeza que deseja excluir esta avaliação?',
          primaryText: 'Excluir',
          primaryStyle: _DialogButtonStyle.danger,
          onPrimary: () async {
            try {
              await ProfessionalManagementService
                  .deleteProfessionalReviewAsync(reviewId);
              await _loadProfessionalImageAndReviewList();
              await _loadProfessionalData();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avaliação excluída com sucesso!'),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Erro ao deletar avaliação: $e');
            }
          },
        );
      },
    );
  }

  void _showHireServicePlanDialog(ServicePlanDto plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ThemedAlertDialog(
          title: 'Contratar Plano',
          content:
          'Deseja contratar o plano "${plan.title}" por ${'R\$ ${plan.price.toStringAsFixed(2)}'}?',
          primaryText: 'Contratar',
          onPrimary: () async {
            try {
              await ProfessionalManagementService
                  .addServicePlanToClientAsync(
                loggedInUserProfileId,
                plan.id,
              );
              await _loadClientData();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plano contratado com sucesso!'),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Erro ao contratar plano: $e');
            }
          },
        );
      },
    );
  }

  void _showEditReviewDialog(ClientProfessionalReviewDto review) {
    final TextEditingController commentController =
    TextEditingController(text: review.comment);
    int updatedRating = review.rating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SheetDialog(
          title: 'Editar Avaliação',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FieldGroup(
                label: 'Nota',
                child: DropdownButtonFormField<int>(
                  dropdownColor: _AppColors.field,
                  value: updatedRating,
                  decoration: _fieldDecoration(),
                  items: List.generate(
                    5,
                        (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(color: Colors.white), // Define o texto branco
                      ),
                    ),
                  ),
                  onChanged: (v) => updatedRating = v ?? updatedRating,
                ),
              ),
              _FieldGroup(
                label: 'Comentário',
                child: TextFormField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: _fieldDecoration(),
                  style: const TextStyle(color: Colors.white), // Define o texto branco
                ),
              ),
            ],
          ),
          primaryText: 'Salvar',
          onPrimary: () async {
            try {
              await ProfessionalManagementService.updateProfessionalReviewAsync(
                review.id,
                commentController.text,
                updatedRating,
              );
              await _loadProfessionalImageAndReviewList();
              await _loadProfessionalData();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avaliação atualizada com sucesso!'),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Erro ao atualizar avaliação: $e');
            }
          },
        );
      },
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: _AppColors.field,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// ======= UI COMPONENTS =======

class _TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  const _TopAppBar({
    required this.title,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: _AppColors.bg,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: _AppColors.border, width: 1),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (trailing != null) trailing!,
        const SizedBox(width: 8),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double? rating;
  final int? totalReviews;

  const _ProfileHeader({
    required this.name,
    this.imageUrl,
    this.rating,
    this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _AppColors.border,
          radius: 32,
          backgroundImage: NetworkImage(
            imageUrl?.isNotEmpty == true
                ? imageUrl!
                : 'https://via.placeholder.com/64',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              if (rating != null && totalReviews != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: _AppColors.amber),
                      const SizedBox(width: 6),
                      Text(
                        '${rating!.toStringAsFixed(1)} (${totalReviews} ${totalReviews == 1 ? 'review' : 'reviews'})',
                        style: const TextStyle(
                          color: _AppColors.text,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10, left: 16, right: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: _AppColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Widget child;
  final bool dim; // quando true, dá efeito "disabled"
  const _GradientCard({required this.child, this.dim = false});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF191F2B),
            Color(0xFF101827),
          ],
        ),
        color: _AppColors.card,
        border: Border.all(color: _AppColors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
    return dim ? Opacity(opacity: 0.55, child: content) : content;
  }
}

class _PlanRow extends StatelessWidget {
  final String title;
  final String description;
  final String typeLabel;
  final bool isHired;
  final String priceLabel;
  final VoidCallback? onTapAction;

  const _PlanRow({
    required this.title,
    required this.description,
    required this.typeLabel,
    required this.isHired,
    required this.priceLabel,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Esquerda
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: _AppColors.muted,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _AppColors.field,
                  border: Border.all(color: _AppColors.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    color: _AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Direita
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isHired)
            // selo contratado (fica acinzentado via `dim` no card)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF101827),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Contratado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: onTapAction,
                child: const Text(
                  'Contratar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
            const SizedBox(height: 6),
            if (!isHired)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1F3B82F6),
                  border: Border.all(color: Color(0xFF335EA8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priceLabel,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final DateTime lastUpdated;
  final bool canEditDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.comment,
    required this.lastUpdated,
    required this.canEditDelete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = lastUpdated.toLocal().toString().split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: _AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                ),
              ),
            ),
            Text(
              'Nota: $rating',
              style: const TextStyle(
                color: _AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (canEditDelete) ...[
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.edit, onTap: onEdit),
              const SizedBox(width: 6),
              _IconBtn(icon: Icons.delete, onTap: onDelete),
            ],
          ],
        ),
        const SizedBox(height: 6),
        if (comment.isNotEmpty)
          Text(
            comment,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Última atualização: $date',
          style: const TextStyle(
            color: _AppColors.muted,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AppColors.field,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child:  SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

// ======= DIALOG COMPONENTS =======

enum _DialogButtonStyle { primary, danger }

class _ThemedAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String primaryText;
  final _DialogButtonStyle primaryStyle;
  final VoidCallback onPrimary;

  const _ThemedAlertDialog({
    required this.title,
    required this.content,
    required this.primaryText,
    required this.onPrimary,
    this.primaryStyle = _DialogButtonStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = primaryStyle == _DialogButtonStyle.danger
        ? _AppColors.danger
        : _AppColors.primary;

    // Força estilos para evitar dialog branco
    return AlertDialog(
      backgroundColor: _AppColors.bg,
      titleTextStyle: const TextStyle(
        color: _AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: _AppColors.text,
        fontSize: 14.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: _AppColors.border),
      ),
      title: Text(title),
      content: Text(content),
      actionsPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      actions: [
        _ChipButton(
          label: 'Cancelar',
          onTap: () => Navigator.of(context).pop(),
        ),
        _ChipButton(
          label: primaryText,
          onTap: onPrimary,
          background: primaryColor,
        ),
      ],
    );
  }
}

class _SheetDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String primaryText;
  final VoidCallback onPrimary;

  const _SheetDialog({
    required this.title,
    required this.content,
    required this.primaryText,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _AppColors.bg,
      titleTextStyle: const TextStyle(
        color: _AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: _AppColors.text,
        fontSize: 14.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: _AppColors.border),
      ),
      title: Text(title),
      content: content,
      actionsPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      actions: [
        _ChipButton(
          label: 'Cancelar',
          onTap: () => Navigator.of(context).pop(),
        ),
        _ChipButton(
          label: primaryText,
          onTap: onPrimary,
          background: _AppColors.primary,
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? background;

  const _ChipButton({
    required this.label,
    required this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.transparent;
    final border =
    background == null ? _AppColors.border : Colors.transparent;

    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: _AppColors.muted, fontSize: 13)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
