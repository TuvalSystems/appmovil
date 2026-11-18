# Modificar o actualizar una funcionalidad en TUVAL App Móvil

## Mensaje para copiar

```text
Usa docs/prompts/modificar-funcionalidad.md.
En [pantalla o funcionalidad], actualmente [comportamiento actual].
Necesito [resultado esperado] y conservar [reglas o comportamientos].
Pasos para reproducir o API, si los conozco: [referencia opcional].
Revisa el flujo completo y corrige la causa con el menor cambio necesario.
Identifica el módulo responsable y reutiliza sus archivos y funciones.
No generes archivos, funciones ni abstracciones innecesarias.
Respeta estructura, diseño y convenciones actuales de Flutter.
Solo pruebas: PR hacia develop, aprobado por TuvalSystems, devtuval
o josemg23. No fusiones ni despliegues.
```

El ejemplo es para completar, no una tarea a ejecutar al leerlo.

## Ejemplo completo: limpiar el cliente en guías

Copia este mensaje completo en el chat del agente con appmovil abierto y develop actualizado. Es una solicitud ilustrativa; el agente debe comprobar qué existe antes de implementar.

```text
Usa docs/prompts/modificar-funcionalidad.md y aplica todas sus
instrucciones, incluidas las reglas compartidas que referencia.

En el listado de guías de remisión necesito poder quitar el cliente
seleccionado desde el mismo buscador para volver a consultar las guías
de todos los clientes que mis permisos permitan ver.

Primero comprueba si esta acción ya existe y funciona correctamente.
Si ya está resuelta, informa cómo se utiliza y no dupliques la solución.

Si falta, agrega una acción visible y coherente con el diseño actual
para limpiar el cliente seleccionado.

El comportamiento esperado es:
- Selecciono un cliente y consulto sus guías.
- Pulso la acción para quitar ese cliente.
- El buscador queda sin cliente seleccionado.
- Se conservan los demás filtros activos.
- La paginación vuelve al inicio.
- Se consulta nuevamente sin enviar el filtro de cliente.
- Los resultados anteriores se reemplazan, sin mezclarlos con los nuevos.

Si una consulta anterior termina después de limpiar el cliente,
su respuesta no debe sobrescribir los resultados actuales.
La acción debe respetar los permisos y el punto de venta activo.

No cambies las funciones de firma, lectura QR, adjuntos ni las reglas
de negocio de las guías.

Antes de implementar, revisa el flujo completo e identifica el módulo
responsable, la pantalla, el buscador, su controlador, el provider,
el datasource y los parámetros del API.

Revisa especialmente los recursos existentes de:
- lib/presentation/screens/inventory/delivery_note/
- lib/presentation/shared/widgets/customer_search_card.dart
- lib/presentation/shared/controllers/customer_search_controller.dart
- lib/infrastructure/datasources/delivery_notes_datasource.dart

Estas rutas orientan la revisión; comprueba la implementación actual.
Comunica la causa o el alcance del cambio y qué recursos reutilizarás.

Realiza el menor cambio que resuelva completamente la necesidad.
Respeta las responsabilidades de las capas Flutter y conserva
estructura, diseño, tema, navegación y convenciones de appmovil.

Reutiliza archivos, widgets, funciones y métodos existentes.
No generes archivos, funciones, clases, carpetas ni capas innecesarias.
No reconstruyas la pantalla ni reorganices otros módulos.
Si modificas el buscador o controlador compartido, revisa sus demás
consumidores y conserva su comportamiento.
Justifica cualquier archivo o abstracción nuevos.

Verifica:
- Seleccionar un cliente y consultar sus guías.
- Limpiar el cliente y volver a consultar sin ese filtro.
- Conservar los demás filtros.
- Reiniciar correctamente la paginación.
- Limpiar el cliente mientras hay una consulta pendiente.
- Resultados vacíos, errores y reintento.
- Que los demás consumidores del buscador sigan funcionando.

Ejecuta las comprobaciones de la plantilla y revisa el diff.
No registres firmas, adjuntos ni otras operaciones de negocio para probar.

Crea una rama propia desde origin/develop actualizado.
Publica esa rama y crea un PR hacia develop, únicamente para pruebas.
Solicita aprobación a TuvalSystems, devtuval o josemg23,
distinto del autor del PR. Solo su aprobación cuenta como autorización.

No hagas push directo a develop, no uses bypass, no fusiones,
no actives auto-merge, no despliegues y no toques main ni producción.

Entrega el enlace del PR, el comportamiento anterior y resultante,
los recursos reutilizados, las verificaciones y los pendientes.
```

## Reglas compartidas obligatorias

Lee y aplica las secciones **Alcance**, **Estructura e implementación**, **Modularización obligatoria y alcance mínimo**, **Verificación** y **PR y aprobación de colaboradores** de [crear-funcionalidad.md](crear-funcionalidad.md). Forman parte de esta plantilla; no ejecutes su ejemplo de creación. Si falta ese archivo, informa el bloqueo antes de implementar.

Estas reglas se limitan a colaboradores que invoquen el prompt. No imponen PR ni bloquean subidas del propietario en su trabajo directo fuera del flujo. No configures protecciones globales ni modifiques CODEOWNERS o workflows.

El único destino es `develop` y el ambiente es `qa`, sin tocar `main` ni producción. Solo cuenta como aprobación una revisión humana de `TuvalSystems`, `devtuval` o `josemg23`, distinta del autor. El agente entrega el PR abierto; no fusiona ni despliega.

La modularización es obligatoria: integra el cambio en el módulo responsable, reutiliza sus piezas y justifica cualquier archivo o abstracción nuevos. No crees funciones sin una responsabilidad necesaria ni reorganices módulos ajenos a la tarea.

## Instrucciones específicas para modificar

1. Localiza la implementación por su nombre visible, menú o descripción funcional. Sigue el flujo completo: pantalla, widgets, provider, datasource, modelo y API. No pidas al usuario carpetas técnicas.
2. Para errores, reproduce o identifica la causa antes de corregir. Para ampliaciones, determina qué cambia y qué debe conservarse. Comunica brevemente causa o alcance y recursos reutilizables, sin crear un informe adicional.
3. Realiza el menor cambio que resuelva la necesidad completa. Edita archivos existentes cuando corresponda; crea uno solo si hace falta y sigue el patrón del módulo. No reconstruyas pantallas ni reorganices capas para un ajuste puntual.
4. Mantén contratos, permisos, navegación, filtros, paginación, tema y comportamientos ajenos a la solicitud. Revisa consumidores de widgets, providers y servicios compartidos. No migres de gestor de estado ni dupliques lógica.
5. Comprueba el resultado solicitado y los comportamientos que puedan sufrir regresiones. Si afecta estado asíncrono, revisa cambio de punto de venta, sesión, respuestas atrasadas y cierre de pantalla. Si afecta capacidades nativas, revisa permisos y ciclo de vida correspondientes.
6. Sigue la verificación y entrega compartidas. Resume comportamiento anterior y resultante, archivos nuevos justificados, pruebas, limitaciones y enlace real del PR cuando exista. Si es trabajo solo local, indícalo sin afirmar publicación o aprobación.
