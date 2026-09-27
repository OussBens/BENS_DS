import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/contact_message_model.dart';
import '../../layouts/main_layout.dart';
import '../../providers/contact_provider.dart';
import '../../providers/cordonne_provider.dart';
import '../../widgets/champ_saisie.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  static const _faqs = [
    {
      'q': 'Combien de temps prend un projet type ?',
      'a': 'Un site vitrine prend en général 2 à 4 semaines, une application mobile ou un projet plus complexe entre 6 et 12 semaines selon le périmètre.',
    },
    {
      'q': 'Comment se déroule la demande de devis ?',
      'a': 'Après réception de votre message, nous vous recontactons sous 48h pour cadrer vos besoins puis vous envoyons un devis détaillé sans engagement.',
    },
    {
      'q': 'Proposez-vous de la maintenance après livraison ?',
      'a': 'Oui, nous proposons des forfaits de maintenance et d\'évolution pour garantir la fiabilité de votre produit dans la durée.',
    },
    {
      'q': 'Travaillez-vous avec des startups et petites entreprises ?',
      'a': 'Oui, nous adaptons nos solutions aux besoins et au budget de chaque client, des startups aux entreprises établies.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(cordonneProvider).cordonne == null) {
        ref.read(cordonneProvider.notifier).loadCordonne();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final message = ContactMessage(
      id: 0,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      status: ContactMessageStatus.nouveau,
      createdAt: DateTime.now(),
    );

    final success = await ref.read(contactProvider.notifier).submitMessage(message);

    if (!mounted) return;

    if (success) {
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci ! Votre message a bien été envoyé, nous revenons vers vous sous 48h.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(contactProvider).errorMessage ?? 'Erreur lors de l\'envoi du message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isMobile ? 20.0 : 80.0;
    final isSubmitting = ref.watch(contactProvider).isSubmitting;
    final cordonne = ref.watch(cordonneProvider).cordonne;

    return MainLayout(
      selectedIndex: 3,
      child: Container(
        color: AppColors.bg,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 60 : 100),
              child: Stack(
                children: [
                  Positioned(top: -60, right: -40, child: const GlowBlob(size: 280, color: AppColors.tealGlow)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONTACT', style: AppText.eyebrow.copyWith(letterSpacing: 3, fontSize: 13)),
                      const SizedBox(height: 16),
                      Text(
                        'Parlons de votre projet',
                        style: AppText.h1.copyWith(fontSize: isMobile ? 28 : 42),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isMobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Demande de devis', style: AppText.h2.copyWith(fontSize: 22)),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Nom complet *',
                            controller: _nameController,
                            dark: true,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez entrer votre nom' : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Email *',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            dark: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Veuillez entrer votre email';
                              if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(label: 'Téléphone', controller: _phoneController, keyboardType: TextInputType.phone, dark: true),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Sujet *',
                            controller: _subjectController,
                            dark: true,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez entrer un sujet' : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Message *',
                            controller: _messageController,
                            maxLines: 5,
                            dark: true,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez entrer votre message' : null,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.bg,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Envoyer le message', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 0 : 60, height: isMobile ? 40 : 0),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: glassDecoration(radius: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nos coordonnées', style: AppText.h3.copyWith(fontSize: 18)),
                          const SizedBox(height: 20),
                          if (cordonne?.telephone.isNotEmpty ?? false) _infoRow(Icons.phone_outlined, cordonne!.telephone),
                          if (cordonne?.email.isNotEmpty ?? false) _infoRow(Icons.email_outlined, cordonne!.email),
                          if (cordonne?.adresse.isNotEmpty ?? false) _infoRow(Icons.location_on_outlined, cordonne!.adresse),
                          if (cordonne?.horraire.isNotEmpty ?? false) _infoRow(Icons.schedule_outlined, cordonne!.horraire),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Questions fréquentes', style: AppText.h2.copyWith(fontSize: 24)),
                  const SizedBox(height: 24),
                  ..._faqs.map((faq) => _FaqTile(question: faq['q']!, answer: faq['a']!)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.tealGlow, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 13.5))),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: glassDecoration(radius: 14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.tealGlow,
          collapsedIconColor: AppColors.muted,
          title: Text(question, style: AppText.h3.copyWith(fontSize: 15)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(answer, style: AppText.body)],
        ),
      ),
    );
  }
}
