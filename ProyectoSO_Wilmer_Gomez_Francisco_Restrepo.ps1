#Integrantes
#Wilmer Gomez
#Francisco Restrepo

#Variable de control de las selecciones del usuario
$Selection =-1
Do{
	#Muestra el menu de seleccion para el usuario
	$Selection = Read-Host "Digite el número de las siguientes opciones para ejecutar la acción:
	1.Top 5 de procesos	que más CPU estan consumiendo.
	2.Detalles de los filesystems o discos conectados.
	3.Ver el archivo más grande almacenado en una ubicación.
	4.Ver memoria libre y espacio de swap en uso.
	5.Mostrar el número de conexiones de red activas actualmente."
	
	#Switch que evalua la seleccion del usuario inciando una accion seleccionada o en su defecto reiniciando el menu de opciones
	switch($Selection){
		0{
			#Accion de salida al indicar el valor de 0 en la entrada de texto
			Write-host "Gracias por usar"
			;break
		}
		1 {	
			#Accion numero 1 que aplica un cmdlet y un filtrado de proceso e informacion solicitada en la accion 1
			#get-process | sort -property CPU -desc | select-object -property Name, CPU -First 5 | ft * -Wrap -AutoSize
            get-process | sort -property CPU -desc | select-object -property Name, CPU -First 5 | ft @{n='Nombre del proceso';e={$_.Name}},
            @{n='Uso del CPU';e={[math]::Round($_.CPU / 1,2)}} -Wrap -AutoSize
			;break
		}
   		2 {
			#Accion numero 2 que aplica un comando de acceso a caracteristicas avanzadas de administracion mediante CIM 
   			Get-CimInstance -ClassName Win32_LogicalDisk | 
            ft -Property DeviceID,Volumename, @{n='Tamaño (MB)';e={[math]::Round($_.size / 1mb,2)}},
            @{n='Espacio Libre (MB)';e={[math]::Round($_.freespace / 1mb,2)}} -AutoSize -Wrap
   			;break
   		}
   		3 {
			# se aplica un blucle en la accion 3 para la entrada de la ruta a analizar en la operacion 3, para salir se debe ingresar una ruta
			# bien formada o 0
   			$loopRuta = 1
   			Do{
   				$Ruta = Read-Host "Ingrese la ruta a analizar o 0 para cancelar operación 3"
   				if($Ruta -ne 0){
   					if(!$Ruta){
   		           		Write-Warning "No ha introducido una ruta, ingrese una ruta"
   		       		}else{
                        if((Test-Path -Path $Ruta) -eq "true"){
                            $loopRuta = 0
                            Get-ChildItem -Path $Ruta | sort -Property Length -Descending |Select-Object -Property name,Length -First 1 |
                             ft  @{n='Nombre';e={$_.name}},@{n='Tamaño (MB)';e={[math]::Round($_.Length / 1mb,2)}} -AutoSize -Wrap
                      
                           #ls -Path $Ruta | sort lenght -Descending |ft -Property Name, length
			   #Get-ChildItem -Path $Ruta | sort -Property Length -Descending |Select-Object -Property name,Length,PSPath -First 1 |
                           #  ft  @{n='Nombre';e={$_.name}},@{n='Tamaño (MB)';e={[math]::Round($_.Length / 1mb,2)}},PSPath,@{n='ruta';e={$Ruta}} -AutoSize -Wrap
                        }else{
                           Write-Warning "La ruta ingresada no exite, ingrese otra ruta"
                        }
   		           		
   		       		} 
   				}elseif($Ruta -eq 0){
   					$loopRuta = 0
   				}
   			}While($loopRuta -ne 0)
   			;break
   		}
   		4 {
		#Accion numero 4 que aplica un comando de acceso a caracteristicas avanzadas de administracion mediante WMI para conocer atributos del sistema
            Get-WmiObject -Class WIN32_OperatingSystem |
   			Select-Object -Property FreePhysicalMemory,TotalVirtualMemorySize,FreeVirtualMemory |
   			fl -Property @{n='Memoria libre (GB)';e={[math]::Round($_.FreePhysicalMemory/1mb,2)}},
   			@{n='Porcentaje de swap en uso';e={[math]::Round((($_.TotalVirtualMemorySize-$_.FreeVirtualMemory)/$_.TotalVirtualMemorySize)*100,1)}}
           
   			#Get-CimInstance -ClassName 'Win32_PageFileUsage'| Select-Object -Property CurrentUsage
   			;break
   		}
   		5 {	
			#Accion numero 5 que aplica un cmdlet para contar las conexiones activas del dispositivo indicando la cantidad
			Write-host "El número de conexiones de red activas actualmente en estado ESTABLISHED es de: " 
   			get-NetTCPConnection -State Established | measure | Select -ExpandProperty count
   			;break
   		}
	}
}while($Selection -ne 0)