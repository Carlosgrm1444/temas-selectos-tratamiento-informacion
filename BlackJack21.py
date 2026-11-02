import random
import time

banderaBarraEspaceadora = True
mazo = []
mazoDealer = []
mazoJugador = []
dineroDelJugador = 2000
dineroApostado = 0
nombre = "Jugador"


def main():
  global nombre
  global mazoDealer
  global mazoJugador
  global dineroDelJugador
  
  
  barraEspaceadora()
  inputNombre = input("Cual es tu nombre: ")
  if inputNombre != "":
    nombre = inputNombre
    
  while True:
    mazoDealer.clear()
    mazoJugador.clear()
    
    if dineroDelJugador < 50:
      barraEspaceadora()
      barraEspaceadora()
      print(f"Tienes {dineroDelJugador} no puedes apostar mas, lo siento!! >:(")
      barraEspaceadora()
      barraEspaceadora()
      return
    
    partida()

def partida():
  global mazo 
  global mazoDealer
  global mazoJugador
  global nombre
  global dineroApostado
  global dineroDelJugador

  
  if len(mazo) <= 62:
    mazo = barajeo()
  # print(f"******* {len(mazo)} ********") 
  
  print(f"Has apostado ${pedirDineroApostar()} - Tu saldo actual es de {dineroDelJugador}")

  # * ------- Empieza el default
  barraEspaceadora()
  
  darCartaDealer()
  darCartaJugador()
  darCartaDealer()
  darCartaJugador()
  
  printFirstMazoDealer()
  printFirstMazoJugador()
  
  if int(splitSlash(calcularTotal(mazoJugador, False))) == 21:
      print()
      print("¡¡BLACK JACK!!")
      time.sleep(2) 
      dineroDelJugador += (dineroApostado * 2)
      print(f"Ganaste {nombre}!!, has ganado ${dineroApostado * 2}")
      return
  
  print()
  accion = printAcciones()
  
  # * --- Empieza a comer
  while accion == "1" :
    barraEspaceadora()
    
    darCartaJugador()
    printFirstMazoDealer()
    printFirstMazoJugador()
    print()
    if int(splitSlash(calcularTotal(mazoJugador, False))) > 21:
      print(f"{calcularTotal(mazoJugador, False)} pasa de 21")
      dineroApostado = 0
      print("Perdiste, gracias por jugar")
      return
    
    accion = printAcciones()
  
  # * --- Empieza el dealer
  print()
  print("------ EMPIEZA EL DEALER ------")
  time.sleep(2)  
  barraEspaceadora()
  printSecondMazoDealer()
  printFirstMazoJugador()
  
  if int(splitSlash(calcularTotal(mazoDealer, False))) == 21:
    print()
    print("¡¡BLACK JACK!!")
    time.sleep(2) 
    dineroApostado = 0
    print("Perdiste, gracias por jugar")
    return

  while True :
    time.sleep(2)  
    barraEspaceadora()
    if int(splitSlash(calcularTotal(mazoDealer, False))) == int(splitSlash(calcularTotal(mazoJugador, False))):
      print()
      print("Empate!!")
      dineroDelJugador += dineroApostado 
      print(f"Recuperas ${dineroApostado}")
      break
    elif int(splitSlash(calcularTotal(mazoDealer, False))) > int(splitSlash(calcularTotal(mazoJugador, False))) and int(splitSlash(calcularTotal(mazoDealer, False))) <= 21:
      print()
      print(f"{splitSlash(calcularTotal(mazoDealer, False))} es mayor que {splitSlash(calcularTotal(mazoJugador, False))}")
      dineroApostado = 0
      print("Perdiste, gracias por jugar")
      break
    elif int(splitSlash(calcularTotal(mazoDealer, False))) > 21:
      print()
      print(f"{calcularTotal(mazoDealer, False)} (Dealer) pasa de 21")
      dineroDelJugador += (dineroApostado * 2)
      print(f"Ganaste {nombre}!!, has ganado ${dineroApostado * 2}")
      break
    darCartaDealer()
    printSecondMazoDealer()
    printFirstMazoJugador()

def barajeo():
  cuartobaraja = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
  mazoCompleto = []

  for _ in range(24):
      mazoCompleto.extend(cuartobaraja)

  random.shuffle(mazoCompleto)
  barraEspaceadora()
  print("**************** SE HA BARAJEADO EL MAZO *******************")  
  #print(mazoCompleto)  
  return mazoCompleto

def pedirDineroApostar():
  global dineroDelJugador
  global dineroApostado
  
  while True:
    try:
      barraEspaceadora()
      dineroApostar = int(input(f"Cuánto quieres apostar? - Tu saldo actual es de ${dineroDelJugador}: "))
      
      if dineroApostar > dineroDelJugador:
        print("No cuentas con suficiente dinero, ingresa otra cantidad!!")
      elif dineroApostar < 50:
        print("Debes ingresar al menos $50 para continuar!!")
      else:
        dineroDelJugador -= dineroApostar
        dineroApostado = dineroApostar
        return dineroApostar

    except ValueError:
      print("Ingrese un valor válido")

def darCartaDealer():
  mazoDealer.append(mazo[0])
  mazo.pop(0)

def darCartaJugador():
  mazoJugador.append(mazo[0])
  mazo.pop(0)

def printAcciones():
  accion = input("1.- ➕   2.-🤚: ")
  while accion != "1" and accion != "2":
    accion = input("Porfavor selecciona una opcion correcta:")
  
  return accion

def printFirstMazoDealer():
  global mazoDealer
  
  print(f"Dealer - {calcularTotal(mazoDealer, True)}")
  print("------   ------")
  print(f"|{mazoDealer[0]}   |   |*   |")
  print(f"|   {mazoDealer[0]}|   |   *|")
  print("------   ------")
  
def printSecondMazoDealer():
  global mazoDealer
  r1 = ""
  r2 = ""
  r3 = ""
  r4 = ""
  
  for elemento in mazoDealer:
    r1 += "------   "
    r2 += f"|{elemento}  |   " if elemento == 10 else f"|{elemento}   |   "
    r3 += f"|  {elemento}|   " if elemento == 10 else f"|   {elemento}|   "
    r4 += "------   "
  
  print(f"Dealer - {calcularTotal(mazoDealer, False)}")
  print(r1)
  print(r2)
  print(r3)
  print(r4)
  
def printFirstMazoJugador():
  global mazoJugador
  r1 = ""
  r2 = ""
  r3 = ""
  r4 = ""
  
  for elemento in mazoJugador:
    r1 += "------   "
    r2 += f"|{elemento}  |   " if elemento == 10 else f"|{elemento}   |   "
    r3 += f"|  {elemento}|   " if elemento == 10 else f"|   {elemento}|   "
    r4 += "------   "
  
  print(f"{nombre} - {calcularTotal(mazoJugador, False)}")
  print(r1)
  print(r2)
  print(r3)
  print(r4)

def calcularTotal(mazoParaCalcular, esDealerEnPrimera):
  total = 0
  aces = 0
  
  for elemento in mazoParaCalcular:
    if elemento == "A":
      aces += 1
      total += 1
      # print(f"A {total}")
    elif elemento == "J" or elemento == "Q" or elemento == "K":
      total += 10
      # print(f"{elemento} {total}")
    else:
      total += elemento
      # print(f"  {total}")
    if esDealerEnPrimera:
      break

  if (total + 10) <= 21 and aces > 0:
    totalTexto = f"{total}/{total + 10}"
  else:
    totalTexto = str(total)
        
  return totalTexto

# ? ----------------------- 

def barraEspaceadora():
  global banderaBarraEspaceadora
  print()
  if banderaBarraEspaceadora:
    banderaBarraEspaceadora = False
    print("-----------------------------------------------------------------------------")
  else:
    banderaBarraEspaceadora = True
    print("*****************************************************************************")

def splitSlash(cadena):
    # Dividir la cadena usando el delimitador "/"
    partes = cadena.split('/')
    
    # Verificar si hay más de una parte después de dividir
    if len(partes) > 1:
        # Retornar la parte después del delimitador, eliminando espacios en blanco
        return partes[1].strip()
    else:
        # Retornar la cadena original si no hay un delimitador
        return cadena      

if __name__ == "__main__":
    main()
