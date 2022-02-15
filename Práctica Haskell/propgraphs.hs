import System.IO

--DEFINICIONES TYPE UTILIZADAS
--Tipo Aresta String
type Vertex = String

--Tipo Aresta String
type Aresta = String

--Tipo Label String
type Label = String

--Tipo Propietat String
type Propietat = String

--Tipo E conjunto de Propiedades
type P = [Propietat]

--Tipo Lab conjunto de Labels
type Lab = [Label]

--Tipo V conjunto de Vértices
type V = [Vertex]

--Tipo E conjunto de Aristas
type E = [Aresta]

--Todos los valores de una Propiedad
type Value = String

--Todos los tipos posibles del Valor de una propiedad
type Tvalue = String

--DEFINICIONES DATA UTILIZADAS
--VOA puede ser un vértice o una arista
data VOA = VOA Vertex | Aresta deriving (Eq)

--Definición del Show del VOA
instance Show VOA where
  show (VOA n) = show n

--PropertyGraph es el PropertyGraph que debemos construir compuesto por los diccionarios siguientes
data PropertyGraph = PropertyGraph V E P Ro Lambda Prop Sigma SigmaPlus Props Adyacente| Buit

--DEFINICIONES TYPE DE DICCIONARIOS UTILIZADOS
--Definición del tipo Ro (diccionario) dada una arista devuelve los vértices que conecta
type Ro = (Aresta -> (Vertex, Vertex))

--Función que crea un diccionario Ro
crearRo :: (Vertex, Vertex) -> Ro
crearRo = const

--Función que busca el valor de una arista en Ro
searchRo :: Ro -> Aresta -> (Vertex, Vertex)
searchRo = ($)

--Función que inserta una arista con sus dos vértices en Ro, devuelve un diccionario Ro
insertRo :: Ro -> Aresta -> (Vertex, Vertex) -> Ro
insertRo dict key value x
    | key == x      = value
    | otherwise     = dict x

--Definición del tipo Lambda (diccionario) dado un vértice o arista devuelve su label
type Lambda = (VOA -> Label)

--Función que crea un diccionario Lambda
crearLambda :: Label -> Lambda
crearLambda = const

--Función que busca el Label de un vértice o arista en Lambda
searchLambda :: Lambda -> VOA -> Label
searchLambda = ($)

--Función que inserta un vértice o una arista en Lambda, devuelve un diccionario Lambda
insertLambda :: Lambda -> VOA -> Label -> Lambda
insertLambda dict key value x
   | key == x      = value
   | otherwise     = dict x

--Definición del tipo Prop (diccionario) dada una propiedad devuelve su tipo de valor
type Prop = Propietat -> Tvalue

--Función que crea un diccionario Prop
crearProp :: Tvalue -> Prop
crearProp = const

--Función que busca el tvalue de una propiedad o arista en Prop
searchProp :: Prop -> Propietat -> Tvalue
searchProp = ($)

--Función que inserta una propiedad con su valor en Prop, devuelve un diccionario Prop
insertProp :: Prop -> Propietat -> Tvalue-> Prop
insertProp dict key value x
   | key == x      = value
   | otherwise     = dict x

--Definición del tipo Sigma (diccionario) dado un vértice o arista y una propiedad devuelve su valor
type Sigma = (VOA, Propietat) -> Value

--Función que crea un diccionario Sigma
crearSigma :: Value -> Sigma
crearSigma = const

--Función que busca el valor de un vértice o arista y una propiedad
searchSigma :: Sigma -> (VOA, Propietat) -> Value
searchSigma = ($)

--Función que inserta un vértice o arista y una propiedad, devuelve un diccionario Sigma
insertSigma :: Sigma -> (VOA, Propietat) -> Value -> Sigma
insertSigma dict key value x
   | key == x      = value
   | otherwise     = dict x

--Definición del tipo SigmaPlus (diccionario) dado un vértice o arista y una propiedad devuelve su valor
type SigmaPlus = VOA -> [(Propietat, Value)]

--Función que crea un diccionario SigmaPlus
crearSigmaPlus :: [(Propietat, Value)] -> SigmaPlus
crearSigmaPlus = const

--Función que busca el valor de un vértice o arista y devuelve una lista de propiedades con sus valores
searchSigmaPlus :: SigmaPlus -> VOA -> [(Propietat, Value)]
searchSigmaPlus = ($)

--Función que inserta un vértice o arista y una lista de propiedades y valores, devuelve un diccionario SigmaPlus
insertSigmaPlus :: SigmaPlus -> VOA -> [(Propietat, Value)] -> SigmaPlus
insertSigmaPlus dict key value = \x ->
   if key == x && (searchSigmaPlus dict key) == [("nullp", "nullp")] then value
   else if key == x && (searchSigmaPlus dict key) /= [("nullp", "nullp")] then (searchSigmaPlus dict key) ++ value
   else searchSigmaPlus dict x

--Definición del tipo SigmaPlus (diccionario)dada una propiedad devuelve la lista de voas y valores que la contienen
type Props = Propietat -> [(VOA, Value)]

--Función que crea un diccionario Props
crearProps :: [(VOA, Value)] -> Props
crearProps = const

--Función que busca el valor de una propiedad y devuelve una lista de VOAs con sus valores
searchProps :: Props-> Propietat -> [(VOA, Value)]
searchProps = ($)

--Función que inserta una propiedad y una lista de voa con valores, devuelve un diccionario Props
insertProps :: Props -> Propietat -> [(VOA, Value)] -> Props
insertProps dict key value = \x ->
   if key == x && (searchProps dict key) == [((VOA "nullp"), "nullp")] then value
   else if key == x && (searchProps dict key) /= [((VOA "nullp"), "nullp")] then (searchProps dict key) ++ value
   else searchProps dict x

--Definición del tipo SigmaPlus (diccionario) dado un vértice devuelve sus vértices y aristas adyacentes
type Adyacente = Vertex -> [(Aresta, Vertex)]

--Función que crea un diccionario Adyacente
crearAdyacente :: [(Aresta, Vertex)] -> Adyacente
crearAdyacente = const

--Función que busca el valor de una vértice y devuelve una lista de aristas y vértices
searchAdyacente :: Adyacente-> Vertex -> [(Aresta, Vertex)]
searchAdyacente = ($)

--Función que inserta un vérice y una lista de aristas y vértices, devuelve un diccionario Adyacente
insertAdyacente :: Adyacente -> Vertex -> [(Aresta, Vertex)] -> Adyacente
insertAdyacente dict key value = \x ->
   if key == x && (searchAdyacente dict key) == [(("nullp"), "nullp")]
     then value
   else if key == x && (searchAdyacente dict key) /= [(("nullp"), "nullp")]
     then (searchAdyacente dict key) ++ value
   else searchAdyacente dict x

--FUNCIONES AUXILIARES QUE HE NECESITADO
--Función que coge una línea del fichero1 para posteriormente añadir la arista y vértices correspondientes
addLine :: PropertyGraph -> String -> PropertyGraph
addLine graph linea =
  addEdge graph (head $ words linea) (head $ tail $ words linea) (head $ tail $ tail $ words linea)

--Función que añade una línea del fichero2 para poderla meter en el propertygraph
addLineLabel :: PropertyGraph -> String -> PropertyGraph
addLineLabel graph linea =
  defVLabel graph (VOA (head $ words linea)) (head $ tail $ words linea)

--Función que añade una línea del fichero4 para poderla meter en el propertygraph
addLineProp :: PropertyGraph -> String -> PropertyGraph
addLineProp graph linea =
  defValProp graph (head $ words linea) (head $ tail $ words linea)

--Función que añade unas propiedades con sus valores al PropertyGraph
defValProp :: PropertyGraph -> Propietat -> Value -> PropertyGraph
defValProp (PropertyGraph v e p ro lambda prop sig sigplus props ady) pr val =
  PropertyGraph v e (p ++ [pr]) ro lambda (insertProp prop pr val) sig sigplus props ady

--Función que añade una línea del fichero3 para poderla meter en el propertygraph
addLineSigma :: PropertyGraph -> String -> PropertyGraph
addLineSigma graph linea =
  defVProp graph (VOA (head $ words linea)) (head $ tail $ words linea) (head $ tail $ tail $ words linea)

--FUNCIONES UTILIZADAS PARA PRINTAR

--Función que imprime Ro
showRo :: Ro -> E -> IO()
showRo r [x] = do
   putStr x
   print (searchRo r x)
showRo r (x:xs) = do
   putStr x
   print (searchRo r x)
   showRo r xs

--Función que imprime una lista de propiedades y valores
showSigmaPlus :: [(Propietat, Value)] -> IO()
showSigmaPlus [x] = do
   putStr ("(" ++ (fst x) ++ ", " ++ (snd x) ++ ")")

showSigmaPlus (x:xs) = do
   putStr ("(" ++ (fst x) ++ ", " ++ (snd x) ++ ")")
   showSigmaPlus xs

--Función que imprime los vértices con sus correspondientes Labels, props y valores
showVertexs :: Lambda -> SigmaPlus -> V -> IO()
showVertexs l s [x] = do
   putStr (x ++ "[" ++ (searchLambda l (VOA x)) ++ "]{")
   if searchSigmaPlus s (VOA x) /= [("nullp", "nullp")] then showSigmaPlus (searchSigmaPlus s (VOA x))
   else putStr ""
   putStrLn "}"

showVertexs l s (x:xs) = do
   putStr (x ++ "[" ++ (searchLambda l (VOA x)) ++ "]{")
   if searchSigmaPlus s (VOA x) /= [("nullp", "nullp")] then showSigmaPlus (searchSigmaPlus s (VOA x))
   else putStr ""
   putStrLn "}"
   showVertexs l s xs

--Función que imprime las aristas con sus correspondientes Labels, props y valores
showArestes :: Lambda -> SigmaPlus -> Ro -> E -> IO()
showArestes l s ro [x] = do
   putStr ((fst (searchRo ro x)) ++ "-" ++ x ++ "[" ++ (searchLambda l (VOA x)) ++ "]" ++ "->" ++ (snd (searchRo ro x)) ++ "{")
   if searchSigmaPlus s (VOA x) /= [("nullp", "nullp")] then showSigmaPlus (searchSigmaPlus s (VOA x))
   else putStr ""
   putStrLn "}"

showArestes l s ro (x:xs) = do
   putStr ((fst (searchRo ro x)) ++ "-" ++ x ++ "[" ++ (searchLambda l (VOA x)) ++ "]" ++ "->" ++ (snd (searchRo ro x)) ++ "{")
   if searchSigmaPlus s (VOA x) /= [("nullp", "nullp")] then showSigmaPlus (searchSigmaPlus s (VOA x))
   else putStr ""
   putStrLn "}"

   showArestes l s ro xs

--MODIFICADORAS QUE PIDE EL ENUNCIADO
--Función que crea un propertygraph dados 4 ficheros
populate :: String -> String -> String -> String -> PropertyGraph
populate fichero1 fichero2 fichero3 fichero4 = do
   let propertygraph = (PropertyGraph [] [] [] (crearRo (".", ".")) (crearLambda "label") (crearProp "tvalue") (crearSigma "value") (crearSigmaPlus [("nullp", "nullp")]) (crearProps [((VOA "nullp"), "nullp")]) (crearAdyacente [(("nullp"), "nullp")]))
   let propertygraph2 = (foldl addLine propertygraph (lines $ fichero1))
   let propertygraph3 = (foldl addLineLabel propertygraph2 (lines $ fichero2))
   let propertygraph4 = (foldl addLineProp propertygraph3 (lines $ fichero4))
   foldl addLineSigma propertygraph4 (lines $ fichero3)

--Función que añade una arista y dos vértices al propertygraph
addEdge :: PropertyGraph -> Aresta -> Vertex -> Vertex -> PropertyGraph
addEdge (PropertyGraph v e p ro lam prop sig sigplus props ady) a v1 v2 =
   if (elem v1 v) && (elem v2 v)
     then
       PropertyGraph v (e ++ [a]) p (insertRo ro a (v1, v2)) lam prop sig sigplus props
       (insertAdyacente ady v1 [(a, v2)])

   else if (elem v1 v) && (not $ elem v2 v)
     then
       PropertyGraph (v ++ [v2]) (e ++ [a]) p (insertRo ro a (v1, v2)) lam prop sig sigplus props
       (insertAdyacente ady v1 [(a, v2)])

   else if (not $ elem v1 v) && (elem v2 v)
     then
       PropertyGraph (v ++ [v1]) (e ++ [a]) p (insertRo ro a (v1, v2)) lam prop sig sigplus props
       (insertAdyacente ady v1 [(a, v2)])

   else
     PropertyGraph (v ++ [v1] ++ [v2]) (e ++ [a]) p (insertRo ro a (v1, v2)) lam prop sig sigplus props
     (insertAdyacente ady v1 [(a, v2)])

--Función que añade un vertice con su correspondiente propiedad y valor
defVProp :: PropertyGraph -> VOA -> Propietat -> Value -> PropertyGraph
defVProp (PropertyGraph v e p ro lambda pro sigma sigplus props ady) voa prop val =
  PropertyGraph v e p ro lambda pro (insertSigma sigma (voa, prop) val) (insertSigmaPlus sigplus voa [(prop, val)])
  (insertProps props prop [(voa, val)]) ady

--Función que añade una arista con su correspondiente propiedad y valor
defEProp :: PropertyGraph -> VOA -> Propietat -> Value -> PropertyGraph
defEProp (PropertyGraph v e p ro lambda pro sigma sigplus props ady) voa prop val =
  PropertyGraph v e p ro lambda pro (insertSigma sigma (voa, prop) val) (insertSigmaPlus sigplus voa [(prop, val)])
  (insertProps props prop [(voa, val)]) ady

--Función que añade vértice con su correspondiente label
defVLabel :: PropertyGraph -> VOA -> Label -> PropertyGraph
defVLabel (PropertyGraph v e p ro lambda prop sig sigplus props ady) voa label =
  PropertyGraph v e p ro (insertLambda lambda voa label) prop sig sigplus props ady

--Función que añade arista con su correspondiente label
defELabel :: PropertyGraph -> VOA -> Label -> PropertyGraph
defELabel (PropertyGraph v e p ro lambda prop sig sigplus props ady) voa label =
  PropertyGraph v e p ro (insertLambda lambda voa label) prop sig sigplus props ady

--Función que imprime el grafo dado
showGraph :: PropertyGraph -> IO()
showGraph (PropertyGraph v e p ro lambda prop sig sigplus props ady) = do
   showVertexs lambda sigplus v
   putStrLn "............"
   showArestes lambda sigplus ro e


--CONSULTORAS
--Función que dado un vértice o arista devuelve el listado de propiedades y valores
o' :: PropertyGraph -> VOA -> [(Propietat, Value)]
o' (PropertyGraph v e p ro lambda prop sig sigplus props ady) voa = searchSigmaPlus sigplus voa

--Función que dado un natural y una propiedad devuelve los vértices que tienen esa propiedad con su valor
propV :: PropertyGraph -> Int -> Propietat -> [(VOA, Value)]
propV (PropertyGraph v e p ro lambda prop sig sigplus props ady) k pr = take k (searchProps props pr)

--Función que dado un natural y una propiedad devuelve las aristas que tienen esa propiedad con su valor
propE :: PropertyGraph -> Int -> Propietat -> [(VOA, Value)]
propE (PropertyGraph v e p ro lambda prop sig sigplus props ady) k pr = take k (searchProps props pr)

--Función auxiliar de reachable que dado un propertygraph, una lista de vértices con sus respectivas adyacencias, el vértice destino
--devulve true sí el v2 es alcanzable y falso en caso contrario
reachable' :: PropertyGraph -> V -> [(Aresta, Vertex)] -> Vertex -> Label -> Bool
reachable' (PropertyGraph v e p ro lambda prop sig sigplus props ady) visited [adyacente] v2 label =
   if snd adyacente == v2 then True
   else False

reachable' (PropertyGraph v e p ro lambda prop sig sigplus props ady) visited (adyacente:adyacentes) v2 label =
   if (reachable (PropertyGraph v e p ro lambda prop sig sigplus props ady) (snd adyacente) v2 label visited)
     then True
   else
     reachable' (PropertyGraph v e p ro lambda prop sig sigplus props ady)
     (visited ++ [(snd adyacente)]) adyacentes v2 label

--Función que dado un propertygraph dos vértices un label y una lista de vértices visitados
--devulve true sí el v2 es alcanzable y falso en caso contrario
reachable :: PropertyGraph -> Vertex -> Vertex -> Label -> V -> Bool
reachable (PropertyGraph v e p ro lambda prop sig sigplus props ady) v1 v2 label visited =
  if v1 == v2 then True
  else
    reachable' (PropertyGraph v e p ro lambda prop sig sigplus props ady) (visited ++ [v1])
    (searchAdyacente ady v1) v2 label

--Método que genera un menú principal
menuprincipal :: PropertyGraph -> IO()
menuprincipal thePG = do
  putStrLn "********************************************************"
  putStrLn "*                                                      *"
  putStrLn "*                   MENÚ PRINCIPAL                     *"
  putStrLn "*                                                      *"
  putStrLn "********************************************************"
  putStrLn "*           ¿Qué acción quieres realizar?              *"
  putStrLn "*       (Introduce el número correspondiente)          *"
  putStrLn "********************************************************"
  putStrLn "*-------------------MODIFICADORAS----------------------*"
  putStrLn "*-------------------[0] addEdge  ----------------------*"
  putStrLn "*-------------------[1] defVProp ----------------------*"
  putStrLn "*-------------------[2] defEProp ----------------------*"
  putStrLn "*-------------------[3] defVLabel----------------------*"
  putStrLn "*-------------------[4] defELabel----------------------*"
  putStrLn "********************************************************"
  putStrLn "*-------------------CONSULTORAS------------------------*"
  putStrLn "*-------------------[5] showGraph----------------------*"
  putStrLn "*-------------------[6] o'       ----------------------*"
  putStrLn "*-------------------[7] propV    ----------------------*"
  putStrLn "*-------------------[8] propE    ----------------------*"
  putStrLn "*-------------------[9] kHops   ----------------------*"
  putStrLn "*-------------------[10] reachable---------------------*"
  putStrLn "*-------------------[11] Salir    ---------------------*"
  putStrLn "********************************************************"
  x <- getLine

  if x == "0"
    then do
      putStrLn "Introduce una arista:"
      a <- getLine
      putStrLn "Introduce un vértice de origen:"
      vo <- getLine
      putStrLn "Introduce un vértice de destino:"
      vd <- getLine
      let newPG = addEdge thePG a vo vd
      showGraph newPG
      menuprincipal newPG

   else if x == "1"
     then do
       putStrLn "Introduce un vértice:"
       a <- getLine
       putStrLn "Introduce una propiedad"
       vo <- getLine
       putStrLn "Introduce un valor"
       vd <- getLine
       let newPG = defVProp thePG (VOA a) vo vd
       showGraph newPG
       menuprincipal newPG

   else if x == "2"
     then do
       putStrLn "Introduce una arista"
       a <- getLine
       putStrLn "Introduce una propiedad"
       vo <- getLine
       putStrLn "Introduce un valor"
       vd <- getLine
       let newPG = defEProp thePG (VOA a) vo vd
       showGraph newPG
       menuprincipal newPG

   else if x == "3"
     then do
       putStrLn "Introduce un vértice"
       a <- getLine
       putStrLn "Introduce un label"
       vo <- getLine
       let newPG = defVLabel thePG (VOA a) vo
       showGraph newPG
       menuprincipal newPG

   else if x == "4"
     then do
       putStrLn "Introduce una arista"
       a <- getLine
       putStrLn "Introduce un label"
       vo <- getLine
       let newPG = defELabel thePG (VOA a) vo
       showGraph newPG
       menuprincipal newPG

   else if x == "5"
     then do
       showGraph thePG
       menuprincipal thePG

   else if x == "6"
     then do
       putStrLn "Introduce una arista o un vértice:"
       voa <- getLine
       putStr "RESULTADO DE LA CONSULTA: "
       print (o' thePG (VOA voa))
       menuprincipal thePG

   else if x == "7"
     then do
       putStrLn "Introduce un valor entero"
       x <- getLine
       putStrLn "Introduce una propiedad válida"
       prop <- getLine
       let a = read x
       putStr "RESULTADO DE LA CONSULTA: "
       print (propV thePG a prop)
       menuprincipal thePG

   else if x == "8"
     then do
       putStrLn "Introduce un valor entero"
       x <- getLine
       putStrLn "Introduce una propiedad válida"
       prop <- getLine
       let a = read x
       putStr "RESULTADO DE LA CONSULTA: "
       print (propE thePG a prop)
       menuprincipal thePG

   else if x == "10"
     then do
       putStrLn "Introduce un vértice de origen"
       vo <- getLine
       putStrLn "Introduce un vértice de destino"
       vd <- getLine
       putStrLn "Introduce una Label"
       lab <- getLine
       putStr "RESULTADO DE LA CONSULTA: "
       print (reachable thePG vo vd lab [])
       menuprincipal thePG

   else if x == "11"
     then
       putStrLn "Adiós!"

  else putStrLn "Tecla errónea, terminando ejecución"

--Función principal que recogerá los ficheros que usaremos
main :: IO()
main = do
   putStrLn "Introduce los archivos correctos para crear el propertygraph"
   putStrLn "¿Cómo se llama el archivo de las Rho?"
   name1 <- getLine
   fichero1 <- readFile name1
   putStrLn "¿Cómo se llama el archivo de las Lambda?"
   name2 <- getLine
   fichero2 <- readFile name2
   putStrLn "¿Cómo se llama el archivo de las Sigma?"
   name3 <- getLine
   fichero3 <- readFile name3
   putStrLn "¿Cómo se llama el archivo de las Prop?"
   name4 <- getLine
   fichero4 <- readFile name4
   let graph = populate fichero1 fichero2 fichero3 fichero4
   showGraph graph
   putStrLn "PROPERTYGRAPGH CREADO CORRECTAMENTE"
   putStrLn "Accediendo al menú..."
   menuprincipal graph
