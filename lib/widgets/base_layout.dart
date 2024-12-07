import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BaseLayout extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showBackButton;
  final bool showDrawer;
  final Widget? bottomNavigationBar;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const BaseLayout({
    Key? key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.showBackButton = true,
    this.showDrawer = true,
    this.bottomNavigationBar,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(AppTheme.paddingMedium),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
        automaticallyImplyLeading: showBackButton,
        elevation: AppTheme.elevationSmall,
      ),
      drawer: showDrawer ? _buildDrawer(context) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ResponsiveBuilder(
              mobile: _buildBody(context, AppTheme.paddingMedium),
              tablet: _buildBody(context, AppTheme.paddingLarge),
              desktop: _buildBody(context, AppTheme.paddingXLarge),
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildBody(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: body,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.home_work,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'Sistema Vistorias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                Text(
                  'Gestão de Imóveis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Imóveis',
            onTap: () => Navigator.pushNamed(context, '/properties'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment,
            title: 'Vistorias',
            onTap: () => Navigator.pushNamed(context, '/inspections'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Clientes',
            onTap: () => Navigator.pushNamed(context, '/clients'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Configurações',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Sair',
            onTap: () {
              // Implementar logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

// Widget para criar cards responsivos e consistentes
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const BaseCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).cardTheme.color,
      elevation: elevation ?? AppTheme.elevationSmall,
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.paddingMedium),
          child: child,
        ),
      ),
    );
  }
}

// Widget para criar formulários responsivos e consistentes
class BaseForm extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final int columns;

  const BaseForm({
    Key? key,
    required this.children,
    this.padding,
    this.columns = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildSingleColumn(),
      tablet: _buildMultiColumn(2),
      desktop: _buildMultiColumn(columns),
    );
  }

  Widget _buildSingleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _addSpacing(children),
    );
  }

  Widget _buildMultiColumn(int columnCount) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columnCount) {
      final rowChildren = <Widget>[];
      for (var j = 0; j < columnCount && i + j < children.length; j++) {
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: j > 0 ? AppTheme.paddingMedium : 0,
              ),
              child: children[i + j],
            ),
          ),
        );
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowChildren,
      ));
    }
    return Column(
      children: _addSpacing(rows),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets) {
    return widgets
        .expand((widget) => [
              widget,
              const SizedBox(height: AppTheme.paddingMedium),
            ])
        .toList()
      ..removeLast();
  }
}

// Widget para criar botões de ação responsivos e consistentes
class BaseActionButtons extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final bool reverse;

  const BaseActionButtons({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttons = reverse ? children.reversed.toList() : children;

    return ResponsiveBuilder(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
      tablet: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: buttons
            .expand((child) => [
                  child,
                  const SizedBox(width: AppTheme.paddingMedium),
                ])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
