// A1. Comprobación de base de datos y colecciones
use saborya
db.getName()
show collections

// A2. Cuenta los documentos de cada una de las cuatro colecciones.
print("Restaurantes: " + db.restaurantes.countDocuments())
print("Clientes: " + db.clientes.countDocuments())
print("Productos: " + db.productos.countDocuments())
print("Pedidos: " + db.pedidos.countDocuments())

//A3 insertar restaurante 
db.restaurantes.insertOne({
  _id: "R11",
  nombre: "Café Arriero",
  categoria: "Cafetería",
  ciudad: "Medellín",
  barrio: "Laureles",
  calificacion: 4.5,
  domicilio: true,
  ubicacion: { type: "Point", coordinates: [-75.5925, 6.2442] },
  etiquetas: ["café", "postres"]
})

// A4. Insertar los dos productos para R11
db.productos.insertMany([
  { _id: "P25", restaurante_id: "R11", nombre: "Tinto campesino", tipo: "bebida", precio: 3500, stock: 100, disponible: true, volumen_ml: 200 },
  { _id: "P26", restaurante_id: "R11", nombre: "Torta de zanahoria", tipo: "postre", precio: 9000, stock: 20, disponible: true, descripcion: "Porción de torta casera" }
])

db.restaurantes.find({ ciudad: "Medellín" }, { nombre: 1, barrio: 1, _id: 0 })
db.productos.countDocuments({ restaurante_id: "R11" })

//B

db.pedidos.countDocuments({ fecha: { $not: { $type: "date" } } })
db.productos.countDocuments({ precio: { $type: "string" } })

//b3 

db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["restaurante_id", "cliente", "calificacion", "texto", "fecha"],
      properties: {
        restaurante_id: { bsonType: "string" },
        cliente: {
          bsonType: "object",
          required: ["id", "nombre"],
          properties: {
            id: { bsonType: "string" },
            nombre: { bsonType: "string" }
          }
        },
        calificacion: {
          bsonType: "int",
          minimum: 1,
          maximum: 5
        },
        texto: {
          bsonType: "string",
          minLength: 5
        },
        fecha: { bsonType: "date" },
        fotos: {
          bsonType: "array",
          maxItems: 4,
          items: { bsonType: "string" }
        }
      }
    }
  }
})