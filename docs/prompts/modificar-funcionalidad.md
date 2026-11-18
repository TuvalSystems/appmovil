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

## Ejemplo práctico: limpiar el cliente seleccionado en guías

Este caso es ilustrativo y no afirma que el comportamiento falte actualmente. Comprueba primero si ya está resuelto; no dupliques una solución existente.

```text
Usa docs/prompts/modificar-funcionalidad.md.

En el listado de guías de remisión necesito poder quitar el cliente
seleccionado desde el mismo buscador para volver a consultar las guías
de todos los clientes que mis permisos permitan ver.

Revisa primero si esa acción ya existe. Si falta, añade una acción clara
para limpiar el cliente. Debe conservar los demás filtros activos,
reiniciar la paginación y consultar nuevamente sin el filtro de cliente.
No cambies firmas, lectura QR, adjuntos, permisos ni reglas de las guías.

Reutiliza el buscador y su controlador compartido, el provider y el
datasource existentes. Conserva estructura, diseño y tema; revisa otros
consumidores si necesitas modificar un recurso compartido.
Verifica seleccionar y limpiar un cliente, la combinación con otros
filtros, la paginación y las respuestas atrasadas.

Crea una rama desde origin/develop actualizado y entrega un PR a develop,
solo para pruebas. Solicita aprobación a TuvalSystems, devtuval o
josemg23, distinto del autor. No hagas push directo al destino,
no uses bypass, no fusiones, no despliegues y no toques main ni producción.
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
