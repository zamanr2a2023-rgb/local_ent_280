# Operational Trip UI Identity Matrix

## Objetivo
- Eliminar IDs técnicos visíveis por defeito nos ecrãs operacionais de viagem.
- Priorizar identidade legível via dados já presentes no snapshot (`snapshot-only`).

## P0 (durante operação)
| Ecrã/Widget | Campo técnico atual | Mostrar por defeito | Fonte | Fallback |
|---|---|---|---|---|
| `manager_trips_screen.dart` card | `trip.id` no título | `pickup -> destination`, cliente/motorista/viatura legíveis | `trip` snapshot (`clientSupport`, `participants.*Summary`) | `Referência ABCD...WXYZ` |
| `manager_trip_detail_screen.dart` app bar | `widget.tripId` | `Detalhe operacional` | UI copy | n/a |
| `manager_trip_detail_screen.dart` recusas | `entry.driverId` | nome do motorista quando disponível | `trip.participants.driverSummary` | `Referência ABCD...WXYZ` |
| `reports_firestore_data_source.dart` | fallback para ID cru em label | `summary.displayName/plate` | `clientSummary`, `driverSummary`, `vehicleSummary` | `Referência ABCD...WXYZ` |

## P1 (detalhe pós-operação)
| Ecrã/Widget | Campo técnico atual | Mostrar por defeito | Fonte | Fallback |
|---|---|---|---|---|
| `client_trip_detail_screen.dart` | ausência de secção de identidade consolidada | secção Participantes (cliente/motorista/viatura) | `trip` snapshot | `Referência ABCD...WXYZ` |
| `driver_trip_detail_screen.dart` | ausência de secção de identidade consolidada | secção Participantes (cliente/motorista/viatura) | `trip` snapshot | `Referência ABCD...WXYZ` |

## P2 (suporte/backoffice)
| Ecrã/Widget | Campo técnico atual | Mostrar por defeito | Fonte | Fallback |
|---|---|---|---|---|
| `admin_audit_entry_card.dart` | `subject` potencialmente ID cru | subject contextual legível | `AuditEntry.subject` | `Referência ABCD...WXYZ` |
| `admin_audit_detail_screen.dart` | `subject` potencialmente ID cru | subject contextual legível | `AuditEntry.subject` | `Referência ABCD...WXYZ` |

## Regra transversal
- IDs completos (`tripId`, `clientId`, `driverId`, `vehicleId`, `adminId`) só em secção colapsável **Detalhes técnicos** com ação de copiar.
- Sem lookup adicional de `users/vehicles` para resolver nome nesta entrega.
