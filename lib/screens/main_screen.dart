import 'package:flutter/material.dart';
import 'package:smart_city/models/domain.dart';
import 'package:smart_city/screens/domain_screen_form.dart';

List<Domain> domains = [
  Domain(
    id: 1,
    name: "Securité",
    icon: Icons.security,
  ),
  Domain(
    id: 2,
    name: "Santé",
    icon: Icons.health_and_safety,
  ),
  Domain(
    id: 3,
    name: "Infrastructure",
    icon: Icons.home,
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart City'),
      ),
      body: const DomainGridLayout(),
    );
  }
}

class DomainGridLayout extends StatelessWidget {
  const DomainGridLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 100,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: domains.length,
      itemBuilder: (context, index) {
        Domain domain = domains[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DomainScreenForm(domain: domain),
              ),
            );
          },

          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  domain.icon,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  domain.name,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DomainListLayout extends StatelessWidget {
  const DomainListLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: domains.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        Domain domain = domains[index];
        return Column(
          children: [
            Row(
              children: [
                Icon(
                  domain.icon,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  domain.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey[700],
            ),
          ],
        );
      },
    );
  }
}
