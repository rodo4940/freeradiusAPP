import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class NasCard extends StatelessWidget {
  // Propiedades del Card
  final String name;
  final String ip;
  final String description;
  final bool online;
  // Constructor -> Se llama automaticamente cuando creas un objeto de esta clase
  const NasCard({
    super.key,
    required this.name,
    required this.ip,
    required this.description,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        //Todos los widgets tiene ya estructura definida
        leading: HeroIcon(HeroIcons.server), //Widget al inicio
        title: Text(
          name, 
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,//Segun Modo Claro u Oscuro
          )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ip, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              maxLines: 1, // corta la descripción si es muy larga
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          //Witget al final
          mainAxisSize: MainAxisSize.min,//Evita que ocupe todo el espacio horizontal
          children: [
            Icon(
              Icons.circle,
              size: 14,
              color: online ? Colors.green.shade600 : Colors.red,
            ),
            // const SizedBox(width: 6),
            // Icon(
            //   Icons.arrow_forward_ios,
            //   size: 16,
            //   color: theme.iconTheme.color,
            // ),
          ],
        ),
        onTap: () {
          // Aquí podrías ir a una pantalla de detalle
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Seleccionaste $name')));
        },
      ),
    );
  }
}
