import 'package:flutter/material.dart';
import '../models/organization_model.dart';

class OrganizationList extends StatelessWidget {
  final List<OrganizationModel> organizations;
  final Function(OrganizationModel) onEdit;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const OrganizationList({
    Key? key,
    required this.organizations,
    required this.onEdit,
    required this.hasMore,
    required this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore();
        }
        return true;
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: organizations.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == organizations.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final org = organizations[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                child: org.logoUrl == null
                    ? Text(org.name.substring(0, 1).toUpperCase())
                    : null,
              ),
              title: Text(org.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plano: ${org.planType}'),
                  Text(
                    org.isTrialActive
                        ? 'Trial: ${org.remainingDaysInTrial} dias restantes'
                        : 'Status: ${org.isActive ? "Ativo" : "Inativo"}',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIndicator(org),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => onEdit(org),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(OrganizationModel org) {
    Color color;
    String tooltip;

    if (!org.isActive) {
      color = Colors.red;
      tooltip = 'Inativo';
    } else if (org.isTrialActive) {
      color = Colors.orange;
      tooltip = 'Em trial';
    } else {
      color = Colors.green;
      tooltip = 'Ativo';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: 12,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
