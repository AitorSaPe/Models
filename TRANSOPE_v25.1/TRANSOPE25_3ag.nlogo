directed-link-breed [arrows arrow]
breed [opers oper]
breed [trans tran]
breed [carriers carrier]
turtles-own [time contracts closeness competitiveness trust availability K valor-neto S original-color MGD Z P Ki gd_parcial]
patches-own [learning original-pcolor]
arrows-own [path weight ordinal]
opers-own [proxi-to-expeds price_opers]
trans-own [distance-to-opers price_trans distance-to-trans1 S_trans1]
carriers-own [distance-to-trans distance-to-trans2 occupied? price_carriers costs kms kms_day]
globals [closeness_verde closeness_cyan closeness_rosa closeness_gris linked_trans linked_carriers excluded_carriers no_linked_carriers
chain_distance global_distance
value_chain net_value
green-agents pink-agents cyan-agents grey-agents density_cyan density_rosa density_verde density_gris
density_trans not_density_trans density_carriers not_density_carriers
density2_trans density2_carriers not_density2_trans not_density2_carriers
gd-green gd-grey gd-pink gd-cyan gd-global
edges t-weight agents-in-knowing-areas knowing-agents pasos day-counter cluster_1 cluster_2 cluster_3 cluster_4]
extensions [csv]

to setup
  random-seed new-seed
  if world = "new" [
    ca
  ask patches with [pycor <= 0] [set pcolor 57]
  ask patches with [pxcor >= 0 and pycor >= -2] [set pcolor 127]
  ask patches with [pxcor <= -1 and pycor >= -2] [set pcolor 87]
  ask patches with [pxcor <= 3 and pycor <= -2] [set pcolor 7]
; create-opers freight-forwarders

 let opers-green round ((count patches with [pcolor = 57] * freight-forwarders) / count patches)
      ask n-of 2 patches with [pcolor = 57] [sprout-opers 1]
  let opers-cyan round ((count patches with [pcolor = 87] * freight-forwarders) / count patches)
       ask n-of 2 patches with [pcolor = 87] [sprout-opers 1]
let opers-pink round ((count patches with [pcolor = 127] * freight-forwarders) / count patches)
      ask n-of 3 patches with [pcolor = 127] [sprout-opers 1]
let opers-gray round ((count patches with [pcolor = 7] * freight-forwarders) / count patches)
      ask n-of 3 patches with [pcolor = 7] [sprout-opers 1]
;setxy random-pxcor random-pycor
;move-to one-of patches with [not any? other turtles-here]
 ask opers [ set color pcolor - 4
  set shape "house"
    set size 2]

;  ask patches [if count opers-on patches with [pcolor = [pcolor] of myself] > 1
;    [ask one-of opers-on patches with [pcolor = [pcolor] of myself] [move-to one-of patches with [pcolor != [pcolor] of myself]
;  set color pcolor - 4]]]
  create-trans tr-companies
  [ setxy random-pxcor random-pycor
  move-to one-of patches with [not any? other turtles-here]
  set shape "transportista"
  set size 5
  set color pcolor - 4]
  create-carriers self-e-carrier
  [ setxy random-pxcor random-pycor
  move-to one-of patches with [not any? other turtles-here]
  set color pcolor - 4
  set size 2
  set shape "truck"]
  ask turtles [set original-color color]
    ask patches [set original-pcolor pcolor]]
  if world = "last" [ifelse not any? turtles [user-message "choose 'Detener' and put 'display?' on"]
    [clear-links
    clear-globals
    clear-output
  clear-all-plots
    ask turtles [set color original-color]
    ask carriers [set kms 0
    set kms_day 0
        if any? carriers with [size = 3] [set size 2]]]]
  if world = "import" [ca
    import-world "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope world/escenario 0/transope_world1.csv"
  clear-links
    clear-globals
    clear-output
  clear-all-plots
    ask turtles [set color original-color]
    ask carriers [set kms 0
    set kms_day 0
        if any? carriers with [size = 3] [set size 2]]]
  set operations precision ((((600 / trip_kms) * self-e-carrier) * (SMT / 4)) + 1) 0
   ask patches [set pcolor original-pcolor
  set learning 0
  set plabel ""]
  ask turtles [set time 0
  set contracts 0
  set K 0]
  agent-values
  closeness_measure
  gd
;  ask carriers [if costs >= price_carriers [set availability 0
;    set color blue]]; descarte de carriers sin margen en setup y luego cada cambio de día
  select
  selection_chain
  ask arrows with [color = red] [set weight (weight + 1)]
  recalculate-distance
  reset-ticks
  set iteration (iteration + 1)
  set pasos operations - 1
  set day-counter days
  output-print "ordinal source target weight length"; procedimiento inicial para extraer el grafo resultante de la simulación
  foreach sort-on [ordinal] arrows [ q -> ask q [
  output-print (word ordinal word " " (([who] of end1) ) word " " (([who] of end2) ) word " " weight word " " path)]]
 set edges count arrows with [weight = 1]
 set linked_trans count trans with [any? my-links] * 100 / count trans; indicador de conectividad de ETs
 set linked_carriers count carriers with [any? my-links] * 100 / count carriers; indicador de conectividad de TAs
 set excluded_carriers count carriers with [color = blue] * 100 / count carriers; indicador de no participación de TAs por precio insuficiente
 set no_linked_carriers count carriers with [not any? my-links] with [color != blue] * 100 / count carriers; indicador de no participación de TAs por no ser la mejor opción;
 ;; estos indicadores se encuentran también en el procedimiento "share"
end

to agent-values
   ask turtles [ifelse probability-distributions = "gamma" [
    set availability precision (availability_level + (random-gamma 1 9 - random-gamma 1 9)) 4
    set trust precision (trust_level + (random-gamma 1 9 - random-gamma 1 9)) 4
    set competitiveness precision (competitiveness_level + (random-gamma 1 9 - random-gamma 1 9)) 4]
    [set availability availability_level
      set trust trust_level
      set competitiveness competitiveness_level]
  ask opers [set price_opers precision (trip_kms * price_eur/km + (competitiveness * random 100)) 2]
  ask carriers [set costs ((costs_eur/km * trip_kms) + regular_costs) + random 10 - random 10]]
  ask trans [ set availability precision (self-e-carrier / (availability * (SMT * 100))) 4
    set valor-neto precision ((trust + competitiveness) * availability ^ 2) 4]
  ask carriers [set valor-neto precision ((trust + competitiveness) * availability ^ 2) 4]
end

to closeness_measure
ask turtles [
ask other turtles [
set closeness (sum [distance myself] of turtles with [color = [color] of myself]) / 10; primero: Calcula la suma distancias desde cada nodo al resto de nodos de su región
let poblacion count turtles with [color = [color] of myself] - 1; segundo: Calcula la población menos uno mismo
if poblacion = 0 [set poblacion 1]
set closeness precision (closeness / poblacion ) 4 ; tercero: Calcula la media de la distancia euclidea desde cada nodo respecto al resto de nodos de su región (poblacion)
set gd_parcial precision sum [distance myself / 10] of turtles with [who < [who] of myself] with [color = [color] of myself] 4; cuarto: Calcula la suma de distancias desde nodo i a nodo j, siendo i>j
  ]]
end

to gd; procedimiento que calcula la distancia geodésica (Newman, 2003) entre los agentes de cada región. Además, se calcula la media
  if count turtles with [original-color = 53] >= 2 [set gd-green sum [gd_parcial] of turtles with [original-color = 53]; suma de valores de gd_parcial de cada nodo verde (de nodo i a nodo j, siendo i>j)
  set gd-green precision (gd-green / ((count turtles with [original-color = 53] * (count turtles with [original-color = 53] - 1)) / 2)) 4]; fórmula de Newman para la región verde
  if count turtles with [original-color = 3] >= 2 [set gd-grey sum [gd_parcial] of turtles with [original-color = 3]; lo mismo para la los nodos grises
    set gd-grey precision (gd-grey / ((count turtles with [original-color = 3] * (count turtles with [original-color = 3] - 1)) / 2)) 4]; lo mismo para la zona gris
  if count turtles with [original-color = 123] >= 2 [set gd-pink sum [gd_parcial] of turtles with [original-color = 123]; lo mismo para los nodos rosas
    set gd-pink precision (gd-pink / ((count turtles with [original-color = 123] * (count turtles with [original-color = 123] - 1)) / 2)) 4]; lo mismo para la zona rosa
  if count turtles with [original-color = 83] >= 2 [set gd-cyan sum [gd_parcial] of turtles with [original-color = 83]; lo mismo para los nodos cyan
    set gd-cyan precision (gd-cyan / ((count turtles with [original-color = 83] * (count turtles with [original-color = 83] - 1)) / 2)) 4]; lo mismo para la zona cyan
  ask turtles with [original-color = 53] [set MGD gd-green]
      ask turtles with [original-color = 3] [set MGD gd-grey]
      ask turtles with [original-color = 123] [set MGD gd-pink]
      ask turtles with [original-color = 83] [set MGD gd-cyan]
  set gd-global sum [MGD] of turtles
  set gd-global precision (gd-global / ((count turtles * (count turtles - 1)) / 2)) 4
end

to select
  random-seed new-seed
  if any? opers [ask one-of opers [
    ask trans [set distance-to-opers precision (distance myself / 10) 4] ; se establece la distancia euclidiana entre el OL y las ET
    ask trans with [color != [color] of myself] [set distance-to-opers distance-to-opers + (proximity_of_regions)]; distancia euclidiana entre OL y ET de otras regiones
    ask trans [ifelse no_distance? [set S valor-neto][set S precision (valor-neto / ((sqrt (closeness ^ 2 * MGD ^ 2)) * distance-to-opers * distance_impact)) 4
    set S S + K]
    set price_trans precision ([price_opers] of myself * ((100 - %-profit * (2 - SMT) - competitiveness) / 100)) 2]; cálculo de Ptrans respecto al oper que inicia la cadena
    set color yellow
    let available_trans trans with [color = original-color]
    if any? trans with [availability > 0] [
    ask max-one-of available_trans [S] [
    ;ask one-of available_trans with [S > mean [S] of trans][
    set color yellow
    create-arrow-from myself
    ask my-in-arrows with [[color] of end1 = yellow][set color red
    set ordinal max [ordinal] of arrows + 1]]]]
    ask trans with [color = yellow][
    set availability precision (availability - (SMT * 10) / self-e-carrier) 4
    ask carriers with [color = blue or color = red][set occupied? true]
    ask carriers with [color != blue and color != red] [set occupied? false]

    ifelse subcontract [; condición de subcontratación extra: la cadena pasa de 3 agentes (1 OL, 1 ET y 1 TA) a estar formada por 4 (1 OL, 2 ETs y 1 TA)
    set distance-to-trans1 0.1; la ET seleccionada (amarilla) recibe un valor residual de "distancia a sí mismo" = 0.1
    ask other trans [set distance-to-trans1 precision (distance myself / 10) 4; la ET1 pide a las otras ET que calculen la distancia hasta ella
    set price_trans precision ([price_trans] of myself * ((100 - %-profit * (2 - SMT) - competitiveness) / 100)) 4]; se recalcula el precio de las ETs respecto a la la ET1 para que sea menor
    ask other trans with [original-color != [original-color] of myself] [set distance-to-trans1 distance-to-trans1 + proximity_of_regions]; las ETs de otras regiones suman la distancia interregional
    ask trans [set S_trans1 precision (valor-neto / (distance-to-trans1 * (sqrt (closeness ^ 2 * MGD ^ 2)) * distance_impact)) 4]; calcula el valor de selección para el resto de ETs
    set S_trans1 S_trans1 + K
    let available_trans trans with [color = original-color]
    ask max-one-of available_trans [S_trans1] [; se selecciona a la ET con mayor valor (ET2) de entre el resto de ETs
    ask carriers [set distance-to-trans2 precision (distance myself / 10) 4]; la ET2 pide a los TAs que calculen la distancia hasta ella
    ask carriers with [original-color != [original-color] of myself][set distance-to-trans2 distance-to-trans2 + proximity_of_regions]; los TAs de otras regiones suman la distancia interregional
    set color 47; la ET2 se destaca con un color amarillo pálido
    create-arrow-from myself; se crea el link entre ET1 y ET2
    ask my-in-arrows with [[color] of end1 = yellow] with [[breed] of end1 = trans] [set color red; pinta el link de rojo
    set ordinal max [ordinal] of arrows + 1]]
    ask trans with [color = 47] [
    set availability precision (availability - (SMT * 10) / self-e-carrier) 4; reduce disponibilidad a la ET2
    ask carriers [set price_carriers precision ([price_trans] of myself * ((100 - %-profit * (2 - SMT) - competitiveness) / 100)) 4; calcula el precio de los TAs respecto a la la ET2 para que sea menor
    if costs + ((%-profit * costs) / 100) >= price_carriers [
    set availability 0
    set color blue]; descarte de carriers sin margen en setup y luego cada cambio de día
    set S precision (valor-neto / (distance-to-trans2 * (sqrt (closeness ^ 2 * MGD ^ 2)) * distance_impact)) 4; recalcula el valor de selección para los TAs respecto a ET2
    set S S + K]
    if any? carriers with [availability > 0] [
    ask carriers with [color = original-color] with-max [S] [
    set color yellow; la ET2 pide al TA con mayor valor de selección que se vuelva amarillo
    set availability precision (availability - (SMT * 10) / tr-companies) 4
    set kms kms + (trip_kms * 2); suma los kms del viaje a su cuenta de kms totales
    set kms_day kms_day + (trip_kms * 2); suma los kms del viaje a su cuenta de kms diarios
    create-arrow-from myself; se crea el link entre ET2 y TA
    ask my-in-arrows with [[color] of end1 = 47][set color red; pinta el link de rojo
    set ordinal max [ordinal] of arrows + 1]; establece un número de orden para el link
    set occupied? true]]; cambia su estado a ocupado
    ]]; se etiquetan los TAs con el valor de selección respecto a ET2

    [ask carriers [; se ejecuta si no hay condición de subcontratación extra
    set distance-to-trans precision (distance myself / 10) 4; se establece la distancia de las ET a los TAs
    if distance-to-trans = 0 [set distance-to-trans 0.1]
    set price_carriers precision ([price_trans] of myself * ((100 - (%-profit * (2 - SMT)) - competitiveness) / 100)) 2; PRECIO CARRIERS CON TRANS1
    if costs + ((%-profit * costs) / 100) >= price_carriers [
    set availability 0
    set color blue]; descarte de carriers sin margen en setup y luego cada cambio de día
    ask carriers with [original-color != [original-color] of myself] [set distance-to-trans precision (distance-to-trans + (proximity_of_regions)) 4]; corregido de la v.14: "original-color" en vez de "color"
    set S precision (valor-neto / ((sqrt (closeness ^ 2 * MGD ^ 2)) * distance-to-trans * distance_impact)) 4
    set S S + K]
    ifelse any? carriers with [availability > 0] [
    ask one-of carriers with [color = original-color] with-max [S] [
 ;   ask one-of carriers with [S > mean [S] of carriers][
    set color yellow; la ET1 pide al TA con mayor valor de selección que se vuelva amarillo
    set availability precision (availability - (SMT * 10) / tr-companies) 4
    set kms kms + (trip_kms * 2); suma los kms del viaje a su cuenta de kms totales
    set kms_day kms_day + (trip_kms * 2); suma los kms del viaje a su cuenta de kms diarios
    create-arrow-from myself; se crea el link entre ET1 y TA
    ask my-in-arrows with [[color] of end1 = yellow][set color red; pinta el link de rojo
    set ordinal max [ordinal] of arrows + 1]; establece un número de orden para el link
    set occupied? true]]
    [user-message "Any self-employed carrier is available."]
  ]]]
  ask turtles with [color = yellow or color = 47] [set contracts contracts + 1]
  display
 end

to selection_chain
  ask turtles [
  ifelse subcontract
    [if any? carriers with [S >= 0] with [color = yellow]
  [set value_chain [S] of one-of trans with [color = yellow] + [S_trans1] of one-of trans with [color = 47] + [S] of one-of carriers with [color = yellow]
    set net_value ([valor-neto] of one-of trans with [color = yellow] + [valor-neto] of one-of trans with [color = 47] + [valor-neto] of one-of carriers with [color = yellow]) / 3]]
    [if any? carriers with [S >= 0] with [color = yellow] [set value_chain  [S] of one-of trans with [color = yellow] + [S] of one-of carriers with [color = yellow]
    set net_value  ([valor-neto] of one-of trans with [color = yellow] + [valor-neto] of one-of carriers with [color = yellow]) / 2]]]
end

to share
  readjust
  ask turtles [
  set valor-neto precision ((trust + competitiveness) * availability ^ 2) 2]
  select
  recalculate-distance
  ask trans with [color = yellow or color = 47] [set k precision (k + (knowledge-transfer / value_chain)) 4]; aumenta el aprendizaje de ET1
  ask carriers with [color = yellow] [set k precision (k + (knowledge-transfer / value_chain)) 4]; aumenta el aprendizaje de TA1
  ask carriers with [valor-neto = 0] [set valor-neto 1]
  set linked_trans count trans with [any? my-links] ;* 100 / count trans
  set linked_carriers count carriers with [any? my-links] ;* 100 / count carriers
  set excluded_carriers count carriers with [color = blue] ;* 100 / count carriers
  set no_linked_carriers count carriers with [not any? my-links] with [color != blue] ;* 100 / count carriers
  selection_chain
  ask arrows with [color = red] [set weight (weight + 1)]
  set edges count arrows with [weight = 1]
  set t-weight sum [weight] of arrows - count arrows
  set pasos pasos - 1
  if pasos = 0 [set day-counter day-counter - 1]
  ask arrows with [color = red][
  output-print (word ordinal word " " (([who] of end1) ) word " " (([who] of end2) ) word " " weight word " " path)]
; test-agents
  display
tick
end

to readjust; procedimiento para reajustar el sistema
  ask carriers with [occupied? = true] ; el carrier seleccionado no entra en esta regularización
   with [color != blue]; los carriers excluídos por precio pueden tener una nueva oportunidad en la siguiente operación
  [set color red]; PASO 1: Pide a los TAs que no esté excluidos por precio que se vuelvan rojos
  ask carriers with [color = red] [ifelse kms_day < 600 [
    set color original-color]; PASO 3: Pide a todos los TAs no excluidos y con capacidad de hacer más viajes que recobren su color original
    [set kms_day kms_day]]
  ask carriers with [kms_day >= 600] [set color red; PASO 4: Los TAs sin posibilidad de hacer más viajes durante ese día se vuelven rojos y ocupados
  set occupied? true]
  ask trans [if availability <= 0 [set color red]]; si las disponibilidad es 0 o menos las ETs se vuelven rojas
   ask turtles with [color = yellow or color = 47] [
  set color original-color]; pide a las tortugas previamente seleccionadas que recuperen su color original
  ask arrows [set color 19]; pinta los links de gris
   ask turtles [set time time + 1]; cuenta los pasos para cada tortuga
  if pasos = 0 [set pasos operations;
    ask carriers [ifelse kms_day <= 600 [set kms_day 0]
  [set kms_day kms_day - 600]]]; al acabar un día pone el contador de kms diarios a 0
end

to recalculate-distance; calcula la longitud de los links teniendo en cuenta la separación de las regiones
  ask arrows [ifelse [original-pcolor] of [patch-here] of end1 > ( [original-pcolor] of [patch-here] of end2  + 20); si hay links entre agentes situados en
    or [original-pcolor] of [patch-here] of end1 < ( [original-pcolor] of [patch-here] of end2 - 20);; diferentes regiones:
    [set path precision ((link-length / 10) + proximity_of_regions) 2] [set path precision (link-length / 10) 2]]; calcula la distancia y suma la distancia interregional
  ask turtles with [color = yellow or color = 47] [ask my-out-arrows [set chain_distance precision (sum [path] of arrows with [color = 15]) 2]]
   set global_distance sum [path] of arrows; crea dos variables globales: 1) chain_distance es la longitud de la cadena de subcontratación en cada operación
  ;; 2) global_distance no es el sumatorio de chain_distance sino el incremento de distancia en el grafo. P.e. si se producen tres operaciones seguidas entre los mismos agentes el incremento de d será 0.
end

to learning_transfer
  repeat days [ifelse operations = 1 [repeat (operations) [share]]
  [repeat (operations - 1) [share
   if all? trans [color != original-color] or all? carriers [color != original-color] [stop]]]
    ask turtles [set color original-color]
    ask links [set color 108]
    ask turtles [ifelse probability-distributions = "gamma" [set availability precision (availability_level + (random-gamma 1 9 - random-gamma 1 9)) 4]
    [set availability availability_level]]
    ask trans [set availability precision (availability * ((SMT * 100) / self-e-carrier)) 4]

    ask turtles with [any? my-links] [ask patches in-radius spread [
   set learning (sum [contracts] of turtles in-radius spread / (count turtles in-radius spread * knowledge-transfer ^ -1)) ]]
   repeat spread [diffuse learning knowledge-transfer]

    ask patches [ask patches in-radius 1 with [original-pcolor != [original-pcolor] of myself]
      [set learning learning * (1 / (log (1 + proximity_of_regions) 250 + 0.8))]; simula el efecto spillover de learning entre regiones
   set learning precision learning 4]
  ask turtles [set K precision (k + [learning] of patch-here) 4]
  foreach sort-on [learning] patches [ t ->
  ask t [ask patches with [learning > 0][
  set pcolor original-pcolor - (5 * learning * clustering_level)]]]; crea zonas sombreadas donde se concentra mayor actividad
  ask patches with [original-pcolor = 57] [if pcolor < 52 [set pcolor 52]]
  ask patches with [original-pcolor = 7] [if pcolor > 10 or pcolor < 2 [set pcolor 2]]
  ask patches with [original-pcolor = 127] [if pcolor < 122 [set pcolor 122]]
  ask patches with [original-pcolor = 87] [if pcolor < 82 [set pcolor 82]]

  ifelse pasos = 0 []
  [share]
  set edges count arrows
  set t-weight sum [weight] of arrows - edges
  set agents-in-knowing-areas count turtles-on patches with [learning >= mean [learning] of patches]
  let learning-patches patches with [learning >= mean [learning] of patches]
  ask turtles [set knowing-agents count (turtles-on learning-patches) with [any? my-links]]
  z-score
  P-coefficient
  set cluster_1 ((count patches with [learning < mean [learning] of patches * 0.5] * 100) / count patches)
  set cluster_2 ((count patches with [learning >= mean [learning] of patches * 0.5 and learning < mean [learning] of patches] * 100) / count patches)
  set cluster_3 ((count patches with [learning >= mean [learning] of patches and learning < 2 * mean [learning] of patches] * 100) / count patches)
  set cluster_4 ((count patches with [learning >= 2 * mean [learning] of patches]  * 100) / count patches)
  ;print-nodes
  ]
  ;export-output word "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope grafos/escenario 8/graph_dynamic/" (word "graph_dynamic" (word iteration ".csv"))
  ;export-plots
  ;ex-world
end

to z-score; Guimera and Amaral (2005)
  ask turtles with [any? links] [set Ki count my-links with [[original-color] of other-end = [original-color] of myself]
    let Ksi count links with [[original-color] of end1 = [original-color] of myself and [original-color] of end2 = [original-color] of myself]
    / count turtles with [original-color = [original-color] of myself] with [any? my-links]
    let sdKsi standard-deviation [Ki] of turtles with [any? links] with [original-color = [original-color] of myself]
    if sdKsi = 0 [set sdKsi 0.1]
    set z precision ((Ki - Ksi) / sdKsi) 4]
  ask turtles with [not any? links][set z 0]
end

to P-coefficient; Guimera and Amaral (2005)
  ask turtles with [any? links] with [original-color = 3 ] [let K1 count my-links with [[original-color] of other-end = 53]
    let K2 count my-links with [[original-color] of other-end = 123]
    let K3 count my-links with [[original-color] of other-end = 83]
    let PKi count my-links
    if PKi = 0 [set PKi 0.1]
    set p precision (1 - ((Ki / PKi) ^ 2 + (K1 / PKi) ^ 2 + (K2 / PKi) ^ 2 + (K3 / PKi) ^ 2)) 4]
  ask turtles with [any? links] with [original-color = 83 ] [let K1 count my-links with [[original-color] of other-end = 53]
    let K2 count my-links with [[original-color] of other-end = 123]
    let K3 count my-links with [[original-color] of other-end = 3]
    let PKi count my-links
    if PKi = 0 [set PKi 0.1]
    set p precision (1 - ((Ki / PKi) ^ 2 + (K1 / PKi) ^ 2 + (K2 / PKi) ^ 2 + (K3 / PKi) ^ 2)) 4]
  ask turtles with [any? links] with [original-color = 53 ] [let K1 count my-links with [[original-color] of other-end = 83]
    let K2 count my-links with [[original-color] of other-end = 123]
    let K3 count my-links with [[original-color] of other-end = 3]
    let PKi count my-links
    if PKi = 0 [set PKi 0.1]
    set p precision (1 - ((Ki / PKi) ^ 2 + (K1 / PKi) ^ 2 + (K2 / PKi) ^ 2 + (K3 / PKi) ^ 2)) 4]
  ask turtles with [any? links] with [original-color = 123 ] [let K1 count my-links with [[original-color] of other-end = 53]
    let K2 count my-links with [[original-color] of other-end = 83]
    let K3 count my-links with [[original-color] of other-end = 3]
    let PKi count my-links
    if PKi = 0 [set PKi 0.1]
    set p precision (1 - ((Ki / PKi) ^ 2 + (K1 / PKi) ^ 2 + (K2 / PKi) ^ 2 + (K3 / PKi) ^ 2)) 4]
end

to sim
  repeat 30
  [setup
    learning_transfer]
end

;to export-plots
;  export-all-plots word "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope plots/escenario 8/" (word "plot_agents_activity" (word iteration ".csv"))
;end
;
;to print-nodes
;  let file_nodes word "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope grafos/escenario 8/graph_nodes/" (word "graph_nodes" (word iteration ".csv"))
;  let head_nodes (list (list "who" "breed" "original-color" "trust" "precio" "availability" "K" "S" "contracts" "closeness" "Z-score" "P-coefficient" "xcor" "ycor"))
;  let mynodes [(list who breed original-color trust competitiveness availability K S contracts closeness z p xcor ycor)] of turtles
;  set mynodes (sentence head_nodes mynodes)
;  if file-exists? file_nodes [
;  file-delete file_nodes]
;  file-open file_nodes
;  csv:to-file file_nodes mynodes
;  file-close
;end
;
;to test-agents
;  let file_test word "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope testing agents/escenario 8/" (word "test_carriers" (word iteration ".csv"))
;  let head_test (list (list "time" "who" "color" "compet" "trust" "availability" "valor-neto" "valor-total" "precio_carrier" "kms" "kms_día" "dist_geo" "dist_eucl"))
;  let test_carriers [(list time who color competitiveness trust availability valor-neto S price_carriers kms kms_day closeness distance-to-trans)] of carriers with [size = 3]
;  set test_carriers (sentence head_test test_carriers)
;  if file-exists? file_test [
;  file-delete file_test]
;  file-open file_test
;  csv:to-file file_test test_carriers
;  file-close
;  ask carriers [output-print word time (word " " who word " " color word " " competitiveness word " " trust word " " availability
;  word " " valor-neto word " " S word " " price_carriers " " word " " kms word " " kms_day word " " closeness word " " distance-to-trans)]
;end
;
;to ex-world
;  let file_world word "C:/Users/Aitor/Desktop/ni/TESIS/NETLOGO/TRANSOPE/transope world/escenario 8/" (word "transope_world" (word iteration ".csv"))
;  export-world file_world
;end
@#$#@#$#@
GRAPHICS-WINDOW
379
15
797
434
-1
-1
10.0
1
11
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
11
10
74
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
799
10
991
130
agents activity 
time
kms
0.0
50.0
1.0
35.0
true
true
"" "\n"
PENS
"total kms" 1.0 0 -7500403 true "" "plot global_distance"
"chain kms" 1.0 0 -817084 true "" "plot chain_distance"
"value_chain" 1.0 0 -2674135 true "" "plot value_chain"

SWITCH
380
436
504
469
subcontract
subcontract
1
1
-1000

INPUTBOX
10
46
76
106
freight-forwarders
10.0
1
0
Number

INPUTBOX
81
46
155
106
tr-companies
40.0
1
0
Number

INPUTBOX
160
46
232
106
self-e-carrier
80.0
1
0
Number

SLIDER
8
185
166
218
availability_level
availability_level
0
2
0.78
0.01
1
NIL
HORIZONTAL

SLIDER
9
148
166
181
competitiveness_level
competitiveness_level
0
2
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
10
111
167
144
trust_level
trust_level
0
2
1.0
0.01
1
NIL
HORIZONTAL

BUTTON
76
10
137
43
NIL
share
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
170
160
273
205
active tr-comp
linked_trans
2
1
11

MONITOR
275
208
376
253
active carriers
linked_carriers
2
1
11

SLIDER
8
260
167
293
proximity_of_regions
proximity_of_regions
0
40
0.0
1
1
kms
HORIZONTAL

SLIDER
8
223
166
256
clustering_level
clustering_level
0.1
2
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
171
256
272
301
chain_kms
chain_distance
17
1
11

BUTTON
139
10
199
43
go-once
share
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
800
130
967
467
11

INPUTBOX
92
340
166
401
%-profit
12.0
1
0
Number

PLOT
971
132
1250
271
learning_difussion
ticks
%
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"o_links" 1.0 0 -7500403 true "" "plot edges"
"r_links" 1.0 0 -2674135 true "" "plot t-weight"

INPUTBOX
10
405
86
465
price_eur/km
2.0
1
0
Number

INPUTBOX
91
405
165
465
costs_eur/km
0.54
1
0
Number

INPUTBOX
11
340
87
400
trip_kms
150.0
1
0
Number

INPUTBOX
170
405
251
465
regular_costs
60.0
1
0
Number

MONITOR
971
322
1032
367
gd-grey
gd-grey
4
1
11

MONITOR
1035
322
1092
367
gd-green
gd-green
4
1
11

MONITOR
1035
274
1091
319
gd-pink
gd-pink
17
1
11

MONITOR
970
274
1032
319
gd-cyan
gd-cyan
17
1
11

MONITOR
971
370
1166
415
world geodesic distance
gd-global
17
1
11

MONITOR
276
256
377
301
increase_kms
global_distance
2
1
11

MONITOR
1168
274
1246
319
value_chain
value_chain
2
1
11

SLIDER
7
297
167
330
distance_impact
distance_impact
0.1
2
1.0
0.1
1
NIL
HORIZONTAL

SWITCH
507
436
620
469
no_distance?
no_distance?
1
1
-1000

INPUTBOX
326
96
376
156
days
5.0
1
0
Number

BUTTON
201
10
260
43
learning
learning_transfer
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
264
96
324
156
operations
21.0
1
0
Number

INPUTBOX
256
405
306
465
spread
2.5
1
0
Number

INPUTBOX
312
405
362
465
iteration
5.0
1
0
Number

MONITOR
170
208
273
253
blue carriers
excluded_carriers
2
1
11

MONITOR
275
161
376
206
inactive carriers
no_linked_carriers
2
1
11

MONITOR
1168
322
1247
367
once links
edges
17
1
11

MONITOR
1169
370
1248
415
repeted links
t-weight
17
1
11

SLIDER
624
436
796
469
knowledge-transfer
knowledge-transfer
0.1
1
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
972
418
1124
463
NIL
agents-in-knowing-areas
17
1
11

MONITOR
1127
418
1249
463
NIL
knowing-agents
17
1
11

MONITOR
1094
274
1165
319
op_remain
pasos
17
1
11

MONITOR
1095
322
1165
367
day_remain
day-counter
17
1
11

CHOOSER
235
46
376
91
probability-distributions
probability-distributions
"none" "gamma"
1

PLOT
994
10
1249
130
agents behavior
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"active TCs" 1.0 0 -10022847 true "" "plot linked_trans"
"active carriers" 1.0 0 -7500403 true "" "plot linked_carriers"
"inactive carriers" 1.0 0 -2674135 true "" "plot no_linked_carriers"
"knowing-agents" 1.0 0 -955883 true "" "plot knowing-agents"
"agents in k-areas" 1.0 0 -6459832 true "" "plot agents-in-knowing-areas"

BUTTON
262
10
325
43
sim
sim
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
170
111
262
156
world
world
"new" "last" "import"
0

INPUTBOX
170
305
220
400
SMT
0.25
1
0
Number

MONITOR
225
305
287
350
k<x/2
cluster_1
2
1
11

MONITOR
290
305
350
350
k<x
cluster_2
2
1
11

MONITOR
225
355
287
400
k>x
cluster_3
2
1
11

MONITOR
290
355
352
400
k>2x
cluster_4
2
1
11

@#$#@#$#@
## WHAT IS IT?
El modelo TRANSOPE trata de simular el proceso de subcontratación entre empresas dedicadas al transporte de mercancías por carretera (TMC) en un ámmbito geográfico a escala regional. Dichas sucontrataciones forman estructuras denominadas "cadenas de transporte", en las que pueden intervenir una amplia gama de agentes diferenciados. En este modelo los tipos de agente intervinientes, así como las variables y parámetros utilizados, tienen su justificación en la minuciosa observación de la realidad y en la literatura existente sobre el tema. 

## HOW IT WORKS

Los agentes
Esta es la versión 16 del modelo TRANSOPE de selección de proveedores de transporte. En este modelo toman parte 3 tipos de agente: 1) Cargadores (shippers), 2) empresas o agencias de transporte (tr-companies) y 3) transportistas autónomos (self-e-carrier). 
Esta versión incorpora un procedimiento de aprendizaje, que permite a las cadenas de transporte ser más eficientes en función del intercambio de información y conocimiento entre agentes.

El funcionamiento es el siguiente: 1) Se establece el número de operaciones idénticas que el cargador va a expedir en un día, 2) se establece el número de días en los que se va a repetir ese proceso, 3) se determina el radio de influencia que permite el intercambio de información entre agentes. 
Entonces el/los CARGADOR/ES seleccionan a la EMPRESA/AGENCIA DE TRANSPORTE, y esta a su vez escoge a un TRANSPORTISTA AUTÓNOMO. Si la opción OUTSOURCING está en "on", la EMPRESA/AGENCIA DE TRANSPORTE elige a otra EMPRESA/AGENCIA y esta selecciona a un TRANSPORTISTA. De tal modo que las cadenas estarán formadas por 3 agentes (outsourcing "off") o por cuatro (ourtsourcing "on").
Al inicio de cada iteración todos los agentes parte de niveles similares de CONFIANZA (T), COMPETITIVIDAD (P) y DISPONIBILIDAD (D, según los controles de la interfaz. Cuando la simulación se pone en marcha, los agentes van incrementando su valor de confianza cada vez que son seleccionados, mientras que su disponibilidad se reduce por la misma razón.
El criterio de selección es el mejor VALOR NETO: (T + P) * D.
Además cada agente mide la distancia hacia quienes pueden seleccionarles (PROXI-TO-OPERS, PROXI-TO-TRANS) y la distancia geodésica o distancia media de cada agente hasta los agentes de su zona (PROXI-AGENTS), donde a menor valor mayor centralidad.
Si el interruptor NO_DISTANCE? está en "on" la selección se produce de acuerdo con el VALOR NETO. Si está en "off" la selección aplica la fórmula 
S = VALOR NETO / (PROXY-TO-? * sqrt PROXI-AGENTS) 


 

## HOW TO USE IT

Se parte de la siguiente hipótesis: A medida que las empresas y transportistas van acumulando conocimiento en torno a un tipo de operación, estas son capaces de intercambiar dicho conocimiento en función de su proximidad a otros agentes y generar ventajas competitivas por su localización (Méndez, 1997). 
   

## THINGS TO NOTICE

En esta versión 23 se introducen el within-module degree z-score y el coeficiente P (Guimera y Amaral, 2005), para medir cómo de conectado está un nodo en su módulo, y el grado de conexión de un nodo de un módulo con el resto de módulos.

Además, la situación del mercado de transporte (SMC) se introduce para crear un estado de equilibrio (SMT=1), frente a una situación de mayor demanda de servicio que servicio disponible (SMT>1) y frente a una situación de mayor oferta que demanda (SMT<1).

También se corrije la fórmula de selección de PST: (trust+competitivity)*availability ^2 / distancia ^2 * sqrt (closeness ^2 * Dg)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
false
0
Polygon -16777216 true false 120 105 120 150 195 150 165 105
Rectangle -7500403 true true 120 75 120 105
Rectangle -7500403 true true 120 75 135 105
Rectangle -16777216 true false 120 75 135 150

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

transportista
false
0
Rectangle -7500403 true true 105 105 120 150
Rectangle -7500403 true true 120 120 180 150
Rectangle -7500403 true true 135 120 150 120
Rectangle -7500403 true true 135 150 150 120
Rectangle -7500403 true true 180 105 195 150
Rectangle -16777216 false false 165 135 135 150

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>ticks</metric>
    <metric>[dispo] of chof 35</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="18"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="19"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment4" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment5" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment6" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>count edges</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-transfer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shippers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment1" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-transfer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="logistic-operators">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="134"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <exitCondition>ticks = 49</exitCondition>
    <metric>linked_trans</metric>
    <metric>excluded_chofs</metric>
    <metric>no_linked_chofs</metric>
    <metric>linked_chofs</metric>
    <metric>chain_distance</metric>
    <metric>global_distance</metric>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <metric>agents-in-knowing-areas</metric>
    <metric>knowing-agents</metric>
    <metric>value_chain</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
      <value value="5"/>
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentX" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>learning</go>
    <timeLimit steps="1"/>
    <metric>chain_distance</metric>
    <metric>global_distance</metric>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <metric>linked_chofs</metric>
    <metric>linked_trans</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="103"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability">
      <value value="0.59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-transfer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="logistic-operators">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust">
      <value value="0.544"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness">
      <value value="0.529"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-margen">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-distributions">
      <value value="&quot;gamma&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="414"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>learning_transfer</go>
    <timeLimit steps="1"/>
    <metric>edges</metric>
    <metric>t-weight</metric>
    <enumeratedValueSet variable="self-e-carrier">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freight-forwarders">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximity_of_regions">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price_eur/km">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-profit">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tr-companies">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="costs_eur/km">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance_impact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust_level">
      <value value="0.544"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-transfer">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trip_kms">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular_costs">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clustering_level">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-distributions">
      <value value="&quot;gamma&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="availability_level">
      <value value="0.59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subcontract">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competitiveness_level">
      <value value="0.551"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no_distance?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iteration">
      <value value="612"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
1.5
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
1
Line -7500403 false 150 150 90 180
Line -7500403 false 150 150 210 180
Line -7500403 false 150 150 210 180
Line -7500403 false 150 150 90 180

in-info
2.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
15
Line -7500403 false 150 150 90 180
Line -7500403 false 150 150 210 180

info
1.5
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
