// // Ajoutez cet import en haut
// import 'package:flutter/material.dart';
// import 'package:lookup/providers/locale_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// // Dans le build method, après la section Theme, ajoutez:

// // Language Selection
// Card(
//   child: Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppLocalizations.of(context)!.language,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Consumer<LocaleProvider>(
//           builder: (context, localeProvider, child) {
//             return Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     leading: const Icon(Icons.language),
//                     title: Text(AppLocalizations.of(context)!.english),
//                     trailing: localeProvider.locale.languageCode == 'en'
//                         ? const Icon(Icons.check_circle, color: Colors.green)
//                         : null,
//                     onTap: () {
//                       localeProvider.setLocale(const Locale('en'));
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     leading: const Icon(Icons.language),
//                     title: Text(AppLocalizations.of(context)!.french),
//                     trailing: localeProvider.locale.languageCode == 'fr'
//                         ? const Icon(Icons.check_circle, color: Colors.green)
//                         : null,
//                     onTap: () {
//                       localeProvider.setLocale(const Locale('fr'));
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     ),
//   ),
// ),

// const SizedBox(height: 20),
