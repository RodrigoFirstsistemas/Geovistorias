import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResponsiveScreen extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showBackButton;
  final double maxContentWidth;

  const ResponsiveScreen({
    Key? key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.showBackButton = true,
    this.maxContentWidth = 1200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: showBackButton,
      ),
      body: ResponsiveBuilder(
        mobile: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: body,
        ),
        tablet: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth * 0.8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: body,
            ),
          ),
        ),
        desktop: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingXLarge),
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

// Widget para criar cards responsivos
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
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

// Widget para criar formulários responsivos
class ResponsiveForm extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const ResponsiveForm({
    Key? key,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _addSpacing(children),
      ),
      tablet: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _addSpacing(
                children.take((children.length / 2).ceil()).toList(),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _addSpacing(
                children.skip((children.length / 2).ceil()).toList(),
              ),
            ),
          ),
        ],
      ),
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

// Widget para criar botões de ação responsivos
class ResponsiveActionButtons extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveActionButtons({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.reversed.toList(),
      ),
      tablet: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: children
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
