import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_controller.dart';

class PropertyListScreen extends StatelessWidget {
  final PropertyController _propertyController = Get.find<PropertyController>();

  PropertyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle add property
            },
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: _propertyController.properties.length,
          itemBuilder: (context, index) {
            final property = _propertyController.properties[index];
            return ListTile(
              title: Text(property.address),
              subtitle: Text(property.type),
              onTap: () {
                Get.toNamed('/property/${property.id}');
              },
            );
          },
        ),
      ),
    );
  }
}
