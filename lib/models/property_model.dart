import 'package:json_annotation/json_annotation.dart';

part 'property_model.g.dart';

enum PropertyType {
  @JsonValue('residential')
  residential,
  @JsonValue('commercial')
  commercial,
  @JsonValue('industrial')
  industrial,
  @JsonValue('land')
  land,
  @JsonValue('rural')
  rural,
  @JsonValue('apartment')
  apartment,
  @JsonValue('other')
  other
}

// Mapa de subtipos disponíveis para cada tipo de imóvel
const Map<PropertyType, List<String>> propertySubtypes = {
  PropertyType.residential: [
    'Casa',
    'Sobrado',
    'Casa Térrea',
    'Sobrado Geminado',
    'Casa em Condomínio',
    'Chalé',
    'Outro'
  ],
  PropertyType.commercial: [
    'Loja',
    'Sala Comercial',
    'Prédio Comercial',
    'Galpão',
    'Ponto Comercial',
    'Shopping',
    'Outro'
  ],
  PropertyType.industrial: [
    'Galpão Industrial',
    'Fábrica',
    'Armazém',
    'Centro de Distribuição',
    'Outro'
  ],
  PropertyType.land: [
    'Terreno Residencial',
    'Terreno Comercial',
    'Terreno Industrial',
    'Lote',
    'Outro'
  ],
  PropertyType.rural: [
    'Fazenda',
    'Sítio',
    'Chácara',
    'Rancho',
    'Outro'
  ],
  PropertyType.apartment: [
    'Apartamento Padrão',
    'Cobertura',
    'Duplex',
    'Triplex',
    'Studio',
    'Kitnet',
    'Outro'
  ],
  PropertyType.other: ['Outro']
};

@JsonSerializable()
class PropertyModel {
  final String? id;
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  @JsonKey(unknownEnumValue: PropertyType.other)
  final PropertyType type;
  final String? subtype;
  final String organizationId;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get address => '$street, $number${complement != null ? ' - $complement' : ''}, $neighborhood, $city - $state, CEP: $cep';

  PropertyModel({
    this.id,
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.type,
    this.subtype,
    required this.organizationId,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : details = details ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);

  PropertyModel copyWith({
    String? id,
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    PropertyType? type,
    String? subtype,
    String? organizationId,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      organizationId: organizationId ?? this.organizationId,
      details: details ?? Map.from(this.details),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
