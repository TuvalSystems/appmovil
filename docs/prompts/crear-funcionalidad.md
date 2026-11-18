# Crear una funcionalidad en TUVAL App Móvil

## Mensaje para copiar

```text
Usa docs/prompts/crear-funcionalidad.md.
Necesito [pantalla o funcionalidad] para [personas y objetivo].
Debe mostrar [información], permitir [acciones] y respetar [reglas].
Pantalla relacionada o API, si lo conozco: [referencia opcional].
Identifica el módulo responsable e integra allí el cambio reutilizando lo existente.
No generes archivos, funciones ni abstracciones innecesarias.
Respeta estructura, diseño y convenciones actuales de Flutter.
Solo pruebas: PR hacia develop, aprobado por TuvalSystems, devtuval
o josemg23. No fusiones ni despliegues.
```

El ejemplo es para completar, no una tarea a ejecutar al leerlo.

## Ejemplo práctico: consultar existencias

Este caso es ilustrativo, no una funcionalidad pendiente. Cópialo y adapta la necesidad antes de enviarlo al agente.

```text
Usa docs/prompts/crear-funcionalidad.md.

Necesito consultar existencias de artículos desde la app móvil.
Lo utilizarán los vendedores para revisar disponibilidad por bodega.
Debe permitir buscar un artículo por código o descripción y mostrar
las existencias que el API permita consultar para el punto de venta activo.
La consulta será de solo lectura, sin ajustes ni movimientos de inventario.

No conozco el API. Investiga si existe el endpoint y si conviene ampliar
una pantalla actual. No inventes campos, permisos ni endpoints; informa
si falta soporte del backend. Respeta los permisos del usuario.

Reutiliza buscadores, widgets, providers y datasources existentes.
Conserva la estructura, diseño y tema del proyecto. Al cambiar de punto
de venta, limpia los resultados anteriores y evita respuestas atrasadas.
Verifica búsqueda, resultados vacíos, errores y cambio de punto de venta.

Crea una rama desde origin/develop actualizado y entrega un PR a develop,
solo para pruebas. Solicita aprobación a TuvalSystems, devtuval o
josemg23, distinto del autor. No hagas push directo al destino,
no uses bypass, no fusiones, no despliegues y no toques main ni producción.
```

## Alcance

Estas instrucciones aplican a colaboradores que invoquen esta plantilla. No son una política global ni imponen PR al trabajo directo del propietario fuera de este flujo. El propietario puede publicar por su cuenta. Leer el archivo como referencia no equivale a invocarlo.

Solo pruebas: rama `develop`, ambiente `qa`. No trabajar sobre `main` ni producción. No modificar protecciones, permisos, CODEOWNERS o workflows para imponer estas reglas. Este prompt define un procedimiento; no configura restricciones técnicas en GitHub.

## Estructura e implementación

1. Lee las instrucciones aplicables y `docs/guia_desarrollador.md`; contrasta la guía con el código. Revisa una pantalla equivalente, rutas, menú y permisos. Identifica dónde corresponde la necesidad y si basta ampliar algo existente. No pidas carpetas técnicas al usuario; pregunta solo por decisiones de negocio que no puedas investigar.
2. Comunica brevemente los archivos y recursos que reutilizarás. Conserva arquitectura, nombres, idioma, formato y patrones del módulo. No introduzcas gestores de estado, dependencias, capas ni refactorizaciones ajenas al objetivo.
3. Respeta esta distribución real; no crees un archivo por cada fila ni fuerces repositorios en flujos que no los usan:

   | Responsabilidad | Ubicación |
   | --- | --- |
   | Pantallas y widgets del módulo | `lib/presentation/screens/<modulo>/` |
   | Estado y acciones del módulo | Providers del módulo con `ChangeNotifier` y `provider` |
   | Sesión y punto de venta global | `lib/presentation/providers/` |
   | Widgets, controladores y helpers compartidos | `lib/presentation/shared/` |
   | Acceso al API | `lib/infrastructure/datasources/` |
   | Modelos y conversión JSON | `lib/infrastructure/models/` |
   | Servicios nativos y almacenamiento | `lib/infrastructure/services/` |
   | Entidades y contratos cuando el flujo los use | `lib/domain/` |
   | Endpoints, HTTP y errores | `lib/config/http/` |
   | Tema, navegación y ambiente | `lib/config/theme/`, `router/` y `environment/` |

4. Separa UI, estado, HTTP y conversión. No hagas peticiones en `build()` ni concentres todo en una pantalla. Reutiliza `DioClient`, `ApiHandler`, `ApiException`, constantes y modelos. Sigue la inyección de Dio y servicios de `lib/main.dart`; no crees clientes que omitan autenticación o expiración de sesión.
5. Conserva diseño, fuente, espaciado y tema. Reutiliza `AppTheme`, `TuvalAppBar`, `AppActionButton`, `AppToast`, `CurrentPointSaleBadge` y recursos compartidos de búsqueda cuando correspondan. Usa colores del tema, sin duplicar estilos ni añadir colores fijos.
6. Integra navegación mediante `AppRouter`, `MobileMenuMapper` y el menú real del backend. No inventes opciones ni amplíes permisos. Si falta soporte backend, informa el requisito sin presentar simulaciones como integración completa.
7. Revisa contratos reales: parámetros, identificadores, tipos, nulos, filtros, fechas, paginación y errores. Usa lecturas autorizadas en QA. No inventes endpoints o campos ni expongas credenciales o datos personales. Mantén las convenciones Dart y mapea las claves reales del JSON.
8. Respeta sesión, punto de venta, cliente y bodega. Limpia datos dependientes al cambiar contexto. Evita respuestas atrasadas, notificaciones tras `dispose` y uso de contextos desmontados después de operaciones asíncronas. Reutiliza mecanismos existentes.
9. Incluye carga, vacío, error y reintento. Preserva validaciones, biometría y permisos nativos afectados. No registres firmas, cotizaciones u otras operaciones de negocio solo para probar sin autorización específica, incluso en QA.
10. Usa funciones claras, nombres descriptivos y condiciones legibles. Revisa consumidores antes de cambiar recursos compartidos. No silencies errores, desactives lints ni dejes código comentado. Crea solo archivos necesarios, sin copias, informes, abstracciones hipotéticas o documentación adicional por defecto. No reviertas trabajo ajeno.

## Modularización obligatoria y alcance mínimo

Esta es una regla fundamental para crear y modificar funcionalidades, no una recomendación opcional.

1. Antes de implementar, identifica el módulo y submódulo responsables por el proceso de negocio, menú y código existente. Comunica dónde integrarás el cambio y qué archivos, funciones y métodos reutilizarás. No decidas la ubicación solo por una palabra de la solicitud o el nombre del endpoint.
2. Incorpora la funcionalidad en su módulo, respetando las capas actuales. Por ejemplo, guías de remisión corresponde a `inventory/delivery_note` y trampas de vapor a `equipment/steam_traps` en presentación; revisa sus recursos relacionados en infraestructura y configuración. Estos ejemplos orientan la búsqueda, no obligan a crear rutas nuevas.
3. Mantén widgets, providers y helpers exclusivos dentro del módulo según su patrón vigente. Usa los archivos de modelos, datasources y endpoints que ya correspondan a ese flujo. No coloques lógica específica en recursos globales solo por comodidad ni dupliques servicios entre módulos.
4. Reutiliza o amplía una función, método, clase o archivo existente cuando su responsabilidad sea adecuada. Crea uno nuevo únicamente cuando el comportamiento solicitado lo necesite y la separación tenga una responsabilidad concreta. Justifica cada archivo nuevo y cualquier nueva abstracción en la entrega.
5. No generes funciones, métodos, clases, wrappers, parámetros, interfaces, carpetas, archivos vacíos ni capas para usos futuros hipotéticos. Evita helpers de un solo paso que no aporten claridad, funciones que solo reenvían llamadas sin una responsabilidad propia y fragmentación innecesaria. Una función nueva sí puede justificarse por claridad, reglas de negocio, reutilización real o aislamiento de un comportamiento relevante; no concentres todo en un bloque gigante para evitar crear funciones.
6. Promueve código a compartido solo cuando exista reutilización real o una responsabilidad transversal demostrable. Revisa los consumidores y conserva compatibilidad; no diseñes un sistema genérico para resolver una única necesidad local.
7. Modulariza progresivamente el alcance solicitado. No migres todo el proyecto, reorganices otros módulos ni crees automáticamente un árbol de carpetas por cada funcionalidad. Si falta un módulo y el proceso realmente lo requiere, explica su ubicación y crea únicamente las piezas necesarias, siguiendo las capas existentes.
8. Antes de entregar, revisa el diff para retirar código sin uso, duplicaciones, funciones o archivos innecesarios introducidos por esta tarea. No elimines trabajo ajeno. Confirma el módulo elegido, los recursos reutilizados y la necesidad de las nuevas piezas.

## Verificación

- Formatea archivos Dart modificados con `dart format`. Para cambios de aplicación ejecuta `flutter analyze`, `flutter test` si existen pruebas y `flutter build apk --debug --flavor qa --dart-define=APP_ENV=qa`, además de los controles requeridos del proyecto. Distingue fallos previos de los introducidos y no rebajes verificaciones.
- Respeta SDK y dependencias de `pubspec.yaml`, `pubspec.lock` y CI. No actualices dependencias, versión, firma o configuración nativa salvo necesidad de la tarea. No ejecutes scripts de publicación para validar una compilación.
- En dispositivo usa `flutter run --flavor qa --dart-define=APP_ENV=qa`. Confirma el ambiente efectivo en `AppEnvironment`; no uses producción ni confíes en el valor por defecto.
- Reutiliza pruebas y añade solo las que cubran riesgos o comportamientos relevantes. Comprueba visualmente el flujo si hay dispositivo e informa si no lo hubo. Para documentación basta revisar contenido y diff.
- Revisa el diff final. Resume cambios, recursos reutilizados, motivos de archivos nuevos, verificaciones y limitaciones. No afirmes comprobaciones que no ejecutaste.

## PR y aprobación de colaboradores

1. Antes de implementar revisa Git, actualiza con `fetch` y comprueba `origin/develop`. Crea `codex/<descripcion-breve>` desde esa referencia actualizada. No inventes una rama `qa`: este proyecto publica QA desde `develop`. Si falta acceso o destino, informa el bloqueo sin sustituirlo.
2. Conserva cambios ajenos; usa un worktree aislado si hace falta. Incluye únicamente cambios de la tarea en commits y PR.
3. Publica la rama de trabajo y crea o actualiza un PR hacia `develop`. El colaborador y su agente no deben subir directamente al destino ni usar bypass, force-push o cambios de reglas, aunque la sesión tenga privilegios.
4. Solo cuenta como autorización una revisión aprobatoria humana en GitHub de `TuvalSystems`, `devtuval` o `josemg23`. Basta una de esas cuentas, distinta del autor. Comentarios, controles automáticos y aprobaciones de otras personas no sustituyen esa revisión. Solicita revisión a una cuenta permitida distinta del autor; si no puedes, informa el pendiente.
5. Antes de entregar para integración, actualiza la rama de trabajo con `origin/develop`, resuelve conflictos y repite las verificaciones afectadas. Conserva el historial publicado. Si cambia el código tras la aprobación, solicita nueva revisión de la versión final. No declares autorizado un PR con cambios solicitados pendientes.
6. Entrega el enlace real, base, verificaciones y estado de revisión. Deja el PR abierto para integración humana autorizada. El agente no aprueba, fusiona, activa auto-merge ni despliega. El workflow actual publica QA al entrar cambios en `develop`; abrir un PR no autoriza esa publicación.
7. Si solicitan trabajo solo local o indican que publicarán por su cuenta, entrega los cambios sin push ni PR e indica que la revisión del flujo de colaboradores queda pendiente. Esto no autoriza al agente del colaborador a hacer push directo. El propietario conserva su flujo habitual en su trabajo directo fuera de esta plantilla.
8. Si falta acceso, conserva el trabajo e informa el bloqueo. No reemplaces el PR por un push directo ni afirmes que GitHub impide otras aprobaciones: estas reglas pertenecen al prompt.
