﻿//*****************************************************************
// Библиотека: TMSSQL
// Автор: Онянов Виталий (Tavalik.ru)
// Версия от 06.04.2018
//

//*****************************************************************
// ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ

// Структура параметров подключения, описание в процедуре ИнициироватьПараметры()
Перем ПараметрыПодключения Экспорт;
// Переменная для возврата ошибки, если таковая имела место быть
Перем ТекстОшибки Экспорт;
// Переменная для включения отладки. 
Перем РежимОтладки Экспорт;


//*****************************************************************
// ЛОКАЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

//*****************************************************************
// Инициирует параметры подключения к MS SQL Server
//
Процедура ИнициироватьПараметры()
   
	ПараметрыПодключения = Новый Структура;
	
	// Сетевой адрес MS SQL Server 
	ПараметрыПодключения.Вставить("АдресСервераSQL","");
	// Имя пользователя для подключения к MS SQL Server
	ПараметрыПодключения.Вставить("ИмяПользователяSQL","");
	// Пароль пользователя для подключения MS SQL Server
	ПараметрыПодключения.Вставить("ПарольПользователяSQL","");
	// Имя базы данных, в которой по умолчанию будут выполняться все запросы
	ПараметрыПодключения.Вставить("ИмяБазыДанныхSQL","");
	
	// Количество секунд для ожидания подключения
	// По умолчанию - 30
	ПараметрыПодключения.Вставить("ConnectionTimeout",30);
	// Количество секунд для выполнения команды
	// По умолчанию - 600
	ПараметрыПодключения.Вставить("CommandTimeout",600);
	
	// Текст ошибки	
	ТекстОшибки = "";

	// Отладка
	РежимОтладки = Ложь;

КонецПроцедуры

//*****************************************************************
// Возвращает имя файла, построенном по принципу: ИмяБазы + ДатаВремя + Расширение
// Пример: Base_2017_04_28_19_02_12.bak
//
// Параметры:
//		- БазовоеИмя - Строка - Базовое имя для формирования файла
//		- Расширение - Строка - Расширение файла
//		- ДатаИмени - Дата - Дата для формирования имени файла
//
// Возвращает:
//		- Строка - Имя получившегося файла
//
Функция ИмяФайлаНаДату(Знач БазовоеИмя, Расширение, Знач ДатаИмени=Неопределено)

	//Если дата не задана, будет использоваться текущая дата
	Если ДатаИмени = Неопределено Тогда
		ДатаИмени = ТекущаяДата();
	КонецЕсли;
	
	Возврат СокрЛП(БазовоеИмя) + Формат(ДатаИмени,"ДФ=_yyyy_MM_dd_ЧЧ_мм_сс") + "." + Расширение;

КонецФункции

//*****************************************************************
// Проверяет корректность указанного параметра. В случае ошибки генерирует сообщение в переменную "ТекстОшибки"
//
// Параметры:
//		- ИмяПараметра - Строка - Строковое имя параметра для генерации текста ошибки
//		- ЗначениеПараметра - Число или Строка - Значение проверяемого параметра
//		- ВозможныеЗначенияЧисло - Строка - Строка возможных значений параметра разделенных знаком "|"
//		- ВозможныеЗначенияСтрока - Строка - Строка возможных значений параметра разделенных знаком "|"
//		- ПривестиК - Строка - Привести значение парметра к указанному виду. Возможные значения:
//			Строка
//			Число
// Возвращает:
//		- Истина - есть параметр введен корректность
//  	- Ложь - есть ошибки
//
Функция ПроверитьПараметр(ИмяПараметра,ЗначениеПараметра,ВозможныеЗначенияЧисло="",ВозможныеЗначенияСтрока="",ПривестиК="")

	// Если параметр не заполен, нечего проверять
	Если ЗначениеПараметра = "" Тогда
		Возврат Истина;
	КонецЕсли;

	Если ТипЗнч(ЗначениеПараметра) = Тип("Число") Тогда
		ТекВозможныеЗначенияЧисло = СтрЗаменить(ВозможныеЗначенияЧисло,"|",Символы.ПС);
		Для Сч = 1 По СтрЧислоСтрок(ТекВозможныеЗначенияЧисло) Цикл
			Если ЗначениеПараметра = Число(СокрЛП(СтрПолучитьСтроку(ТекВозможныеЗначенияЧисло,Сч))) Тогда
				Если ПривестиК = "Строка" Тогда
					ТекВозможныеЗначенияСтрока = СтрЗаменить(ВозможныеЗначенияСтрока,"|",Символы.ПС);
					ЗначениеПараметра = Врег(СокрЛП(СтрПолучитьСтроку(ТекВозможныеЗначенияСтрока,Сч)));
				КонецЕсли;
				Возврат Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Если ТипЗнч(ЗначениеПараметра) = Тип("Строка") Тогда
		ТекВозможныеЗначенияСтрока = СтрЗаменить(ВозможныеЗначенияСтрока,"|",Символы.ПС);
		Для Сч = 1 По СтрЧислоСтрок(ТекВозможныеЗначенияСтрока) Цикл
			Если Врег(СокрЛП(ЗначениеПараметра)) = Врег(СокрЛП(СтрПолучитьСтроку(ТекВозможныеЗначенияСтрока,Сч))) Тогда
				Если ПривестиК = "Число" Тогда
					ТекВозможныеЗначенияЧисло = СтрЗаменить(ВозможныеЗначенияЧисло,"|",Символы.ПС);
					ЗначениеПараметра = Число(СокрЛП(СтрПолучитьСтроку(ТекВозможныеЗначенияЧисло,Сч)));
				КонецЕсли;
				Возврат Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
		
	ТекстОшибки = "Неверно задан параметр """ + ИмяПараметра + """. Возможные значения: " +
		"{ " + ВозможныеЗначенияЧисло + ?(ВозможныеЗначенияЧисло="",""," | ") + ВозможныеЗначенияСтрока + " }. Текущее значение: " + ЗначениеПараметра;
	
	Возврат Ложь;

КонецФункции



//*****************************************************************
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ


//*****************************************************************
// Выполняет сборс всех параметров подключения к настройкам по умолчанию
//
Процедура ОчиститьПараметры() Экспорт

	ПараметрыПодключения = Неопределено;
	ИнициироватьПараметры();

КонецПроцедуры

//*****************************************************************
// Выполняет запрос в указанной базе данных. 
// Для подключения используются параметры из структуры "ПараметрыПодключения". 
// В случае ошибки текст ошибки записывается в переменную "ТекстОшибки".
//
// Параметры:
//		- ТекстЗапроса - Строка - Текст запроса
//		- БазаДанных - Строка - Название базы данных, в которой выполняется запрос. Если не заполнен, используется имя базы из параметров подключения.
//		- ВозвращатьРезультат - Булево - Возвращать результат запроса в объекте ADODB.Recordset
//
// Возвращает:
//		- Истина или ADODB.Recordset - Если запрос выполнен без ошибок
//		- Неопределено - Если были ошибки
//
Функция ВыполнитьЗапрос(ТекстЗапроса, БазаДанных="", ВозвращатьРезультат = Ложь) Экспорт

	ТекстОшибки = "";
	Если ТекстЗапроса = "" Тогда
		ТекстОшибки = "Не указан запрос!";
		Возврат Ложь;
	КонецЕсли;

	// По умолчанию база данных из параметров подключения
	Если БазаДанных = "" Тогда
		БазаДанных = ПараметрыПодключения.ИмяБазыДанныхSQL;
	КонецЕсли;

	Если РежимОтладки Тогда
		Сообщить("-------------------------------------------");
		Сообщить("Попытка выполнить запрос:");
		Сообщить(ТекстЗапроса);
		Сообщить("-------------------------------------------");	
	КонецЕсли;

	Попытка
        Соединение  = Новый COMОбъект("ADODB.Connection");
        Соединение.ConnectionString =
            "driver={SQL Server};" +
            "server="+ПараметрыПодключения.АдресСервераSQL+";"+
            "uid="+ПараметрыПодключения.ИмяПользователяSQL+";"+
            "pwd="+ПараметрыПодключения.ПарольПользователяSQL+";" +
			"database="+БазаДанных+";";
        Соединение.ConnectionTimeout = ПараметрыПодключения.ConnectionTimeout;
        Соединение.CommandTimeout = ПараметрыПодключения.CommandTimeout;
        // Открытие соединение
        Соединение.Open();
		// Выполним запрос
		Если ВозвращатьРезультат Тогда
			Результат = Соединение.Execute(ТекстЗапроса);
		Иначе
			Соединение.Execute(ТекстЗапроса,,128);
			Результат = Истина;
			// Закроем соединение
			Соединение.Close();
		КонецЕсли;
    Исключение
		ТекстОшибки = ОписаниеОшибки() + Символы.ПС + 
		"Текст запроса: " + Символы.ПС + 
		ТекстЗапроса + Символы.ПС;
		Сообщить(ТекстОшибки);
        Возврат Неопределено;
    КонецПопытки;
	
	Возврат Результат;	
	
КонецФункции

//*****************************************************************
// Создает на сервере MS SQL новую базу данных. Если база данных с данным именем уже существует, ничего не происходит.
//
// Параметры:
//  <ИмяБД>  - 	<Строка> - Имя создаваемой базы данных, если не задано имя берется из свойства ПараметрыПодключения.ИмяБазыДанныхSQL
//
// Возвращаемое значение:
//   <Истина>   	- База данных уже существует или была успешно создана
//	 <Ложь> 		- В работе процедуры были ошибки
//
Функция СоздатьБД(Знач ИмяБД="") Экспорт

	Если Не ЗначениеЗаполнено(ИмяБД) Тогда
		ИмяБД = ПараметрыПодключения.ИмяБазыДанныхSQL;
		Если Не ЗначениеЗаполнено(ИмяБД) Тогда
			ТекстОшибки = "Не задано имя базы данных!";
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;

	ТекстЗапроса = "IF db_id('" + ИмяБД + "') IS NULL CREATE DATABASE [" + ИмяБД + "]";

	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции // СоздатьБД(ИмяБД)

//*****************************************************************
// Удаляет базу данных с сервера MS SQL с указанным именем. Если база данных не найдена на сервере, ничего не происходит.
//
// Параметры:
//  <ИмяБД>  - <Строка> - Имя базы данных для удаления, если не задано имя берется из свойства ПараметрыПодключения.ИмяБазыДанныхSQL 
//
// Возвращаемое значение:
//   <Истина>   - База данных не найдена на сервере или не была удалена
//   <Ложь>   - В работе процедуры были ошибки
//
Функция УдалитьБД(Знач ИмяБД="") Экспорт

	Если Не ЗначениеЗаполнено(ИмяБД) Тогда
		ИмяБД = ПараметрыПодключения.ИмяБазыДанныхSQL;
		Если Не ЗначениеЗаполнено(ИмяБД) Тогда
			ТекстОшибки = "Не задано имя базы данных!";
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;

	ТекстЗапроса = "
	|IF db_id('" + ИмяБД + "') IS NOT NULL BEGIN
	|	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'" + ИмяБД + "'
	|	DROP DATABASE [" + ИмяБД + "]
	|END";

	ВыполнитьСборкуМусора();
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции // УдалитьБД(ИмяБД)

//*****************************************************************
// Удаляет файл на сервере MS SQL
//
// Параметры:
//  <ПолноеИмяФайла>  - Строка - Полное имя к файлу, который необходимо удалить
//
// Возвращаемое значение:
//   <Истина>   - Файл не найден или успешно удален
//	 <Ложь>   - В работе процедуры были ошибки
//
Функция УдалитьФайлНаСервере(ПолноеИмяФайла) Экспорт
	
	Если Не ЗначениеЗаполнено(ПолноеИмяФайла) Тогда
		ТекстОшибки = "Не задано имя файла на сервере MS SQL!";
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = "
	|DECLARE @out as int = 0
	|EXEC master.dbo.xp_fileexist '" + ПолноеИмяФайла + "', @out out
	|IF @out = 1 EXEC master.dbo.xp_delete_file 0, '" + ПолноеИмяФайла + "'";

	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;	
		
КонецФункции // УдалитьФайлНаСервере(ПолноеИмяФайла)

//*****************************************************************
// Получает данные файлов базы данных из параметров подключения.
//
// Возвращает:
//		- ТаблицаЗначений - Таблица со структурой параметров файлов, если не было ошибок. 
//			Колонки таблицы:
//				- ЛогическоеИмя - Строка - Логическое имя файла
//				- ФизическоеИмя - Строка - Физическое имя файла
//				- Тип - Число - Тип файла. Возможные значения: 0 - файл данных, 1 - файл журнала транзакций	
//				- Размер - Число - Размер файла в МБ.
//		- Неопределено - Если были ошибки
//
Функция ПолучитьСтруктуруФайловБД() Экспорт

	// Получим массив файлов текущей базы данных
	ТекстЗапроса = "
	|SELECT
	|	name,
	|	physical_name,
	|	type,
	|	size
	|FROM sys.master_files 
	|WHERE database_id = DB_ID('" + ПараметрыПодключения.ИмяБазыДанныхSQL + "')
	|";
	
	ВыборкаПоФайлам = ВыполнитьЗапрос(ТекстЗапроса,"master",Истина);
	Если ВыборкаПоФайлам = Неопределено Тогда
		ТекстОшибки = "Не удалось получить структуру файлов базы данных " + ПараметрыПодключения.ИмяБазыДанныхSQL;
		Возврат Неопределено;
	КонецЕсли;
	
	// Создаим таблицу
	ТаблицаФайлов = Новый ТаблицаЗначений;
	ТаблицаФайлов.Колонки.Добавить("ЛогическоеИмя"); 	// Логическое имя файла
	ТаблицаФайлов.Колонки.Добавить("ФизическоеИмя"); 	// Физическое имя файла
	ТаблицаФайлов.Колонки.Добавить("Тип");				// 0 - файл данных, 1 - файл журнала транзакций				
	ТаблицаФайлов.Колонки.Добавить("Размер");			// Размер в МБ
	
	// Заполним таблицу данными файлов
	ВыборкаПрочитана = Ложь;
	Попытка 
		Если ВыборкаПоФайлам.BOF = Ложь Тогда
			ВыборкаПоФайлам.MoveFirst();
			Пока ВыборкаПоФайлам.EOF = Ложь Цикл
				НоваяСтрока = ТаблицаФайлов.Добавить();
				НоваяСтрока.ЛогическоеИмя = ВыборкаПоФайлам.Fields("name").Value;
				НоваяСтрока.ФизическоеИмя = ВыборкаПоФайлам.Fields("physical_name").Value;
				НоваяСтрока.Тип = ВыборкаПоФайлам.Fields("type").Value;
				НоваяСтрока.Размер = ВыборкаПоФайлам.Fields("size").Value;
				ВыборкаПоФайлам.MoveNext();
			КонецЦикла;
		КонецЕсли;
		ВыборкаПрочитана = Истина;
	Исключение
		ТаблицаФайлов.Очистить();
	КонецПопытки;
	
	Если Не ВыборкаПрочитана Тогда
		// Не удолось прочитать данные.
		// Попробуем выгрузить в строку.
		Попытка
			ДанныеВСтроке = СокрЛП(ВыборкаПоФайлам.GetString(,,Символы.ПС,Символы.ПС));
			НомерСтолбца = 0;
			Для Сч = 1 По СтрЧислоСтрок(ДанныеВСтроке) Цикл			
				НомерСтолбца = НомерСтолбца + 1;
				Если НомерСтолбца = 1 Тогда
					НоваяСтрока = ТаблицаФайлов.Добавить();
					НоваяСтрока.ЛогическоеИмя = СокрЛП(СтрПолучитьСтроку(ДанныеВСтроке,Сч));
				ИначеЕсли НомерСтолбца = 2 Тогда
					НоваяСтрока.ФизическоеИмя = СокрЛП(СтрПолучитьСтроку(ДанныеВСтроке,Сч));
				ИначеЕсли НомерСтолбца = 3 Тогда
					НоваяСтрока.Тип = Число(СтрПолучитьСтроку(ДанныеВСтроке,Сч));
				ИначеЕсли НомерСтолбца = 4 Тогда
					НомерСтолбца = 0;
					НоваяСтрока.Размер = Число(СтрПолучитьСтроку(ДанныеВСтроке,Сч));
				КонецЕсли;				
			КонецЦикла;
		Исключение
			ТаблицаФайлов.Очистить();
		КонецПопытки;
	КонецЕсли;		
	
	Если ТаблицаФайлов.Количество()  = 0 Тогда
		ТекстОшибки = "Не обнаружены файлы в базе данных " + ПараметрыПодключения.ИмяБазыДанныхSQL;
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ТаблицаФайлов;

КонецФункции

//*****************************************************************
// Создает резервную копию базы данных из параметров подключения.
//
// Параметры:
//		- Каталог - Путь к каталогу для хранения резревной копии. Задается относительно сервера MS SQL Server.
//			Если не задан используется каталог по умолчанию.
//		- ИмяФайла - Имя файла резервной копии.
//			Если не задан, имя формируется автоматически в формате: ИмяБазы_2017_04_28_19_02_12.bak.
//		- ТипРезервнойКопии - Число или Строка - Тип резервной копии, возможные значения:
//			1 или FULL - Полная резервная копия
//			2 или DIFFERENTIAL - Разностная резервная копия
//			3 или LOG - Копия журнала транзакций
//		- ТолькоРезервноеКопирование - Число или Строка - Флаг только резервного копирования, возможные значения:
//			1 или COPY_ONLY - Только резервное копирование
//		- СжиматьРезервныеКопии - Число или Строка - Параметр сжатия резервной копии, возможные значения:
//			1 или COMPRESSION - Сжимать резевную копию
//
// Возвращает:
//		- Строка - Полное имя файла резервной копии, если не было ошибок
//		- Неопределено - Если были ошибки
//
Функция СделатьРезервнуюКопиюБД(Каталог="", ИмяФайла="", Знач ТипРезервнойКопии="", Знач ТолькоРезервноеКопирование = "", Знач СжиматьРезервныеКопии="") Экспорт

	ТекстОшибки = "";
	
	// Проверим корректность введенных параметров
	Если Не ПроверитьПараметр("Тип резервной копии",ТипРезервнойКопии,"1 | 2 | 3","FULL | DIFFERENTIAL | LOG","Число") Тогда 
		Возврат Ложь;
	КонецЕсли;	
	Если Не ПроверитьПараметр("Только резервное копирование",ТолькоРезервноеКопирование,"1","COPY_ONLY","Строка") Тогда 
		Возврат Ложь;
	КонецЕсли;	
	Если Не ПроверитьПараметр("Только резервное копирование",СжиматьРезервныеКопии,"1","COMPRESSION","Строка") Тогда 
		Возврат Ложь;
	КонецЕсли;
	Если ТипРезервнойКопии = 2 
		И ТолькоРезервноеКопирование = "COPY_ONLY" Тогда
		ТекстОшибки = "Нельзя делать разностную резервную копию с флагом ""Только резервное копирование""!";
		Возврат Ложь;
	КонецЕсли;
		
	// Сформируем имя файла, если необходимо
	Если ИмяФайла = "" Тогда
		ИмяФайла = ИмяФайлаНаДату(ПараметрыПодключения.ИмяБазыДанныхSQL, ?(ТипРезервнойКопии=3,"trn","bak"), ТекущаяДата());
	КонецЕсли;
	ПолноеИмяФайла = ОбъединитьПути(Каталог,ИмяФайла);
	
	ТекстЗапроса = 
		"BACKUP " 
		+ ?(ТипРезервнойКопии=3,"LOG","DATABASE") 
		+ " [" + ПараметрыПодключения.ИмяБазыДанныхSQL + "]
		|TO DISK = N'" + ПолноеИмяФайла + "'
		|WITH NOFORMAT, NOINIT,
		|SKIP, NOREWIND, NOUNLOAD, STATS = 10"
		+ ?(СжиматьРезервныеКопии="","",", ") + СжиматьРезервныеКопии
		+ ?(ТолькоРезервноеКопирование="","",", ") + ТолькоРезервноеКопирование
		+ ?(ТипРезервнойКопии=2,", DIFFERENTIAL","");
	
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат ПолноеИмяФайла;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

//*****************************************************************
// Получает последовательность файлов для воосстановления базы данных из параметров подключения на указанную дату.
//
// Параметры:
//		- ВосстановлениеНаДату - Дата - Дата на котороую подбирается последовательность файлов
//			Если не указана, то берется текущая дата.
//
// Возвращает:
//		- Массив - Массив файлов в порядке восстановления, если не было ошибок
//		- Неопределено - Если были ошибки
//
Функция ПолучитьСписокФайловДляВосстановленияБД(Знач ВосстановлениеНаДату = "") Экспорт

	Если НЕ ЗначениеЗаполнено(ВосстановлениеНаДату) Тогда
		ВосстановлениеНаДату = ТекущаяДата();
	КонецЕсли;
	
	ТекстЗапроса = "
	|-------------------------------------------
	|-- ТЕЛО СКРИПТА
	|set nocount on 
	|
	|-- Удалим временные таблицы, если вдруг они есть
	|IF OBJECT_ID('tempdb.dbo.#BackupFiles') IS NOT NULL DROP TABLE #BackupFiles
	|IF OBJECT_ID('tempdb.dbo.#FullBackup') IS NOT NULL DROP TABLE #FullBackup
	|IF OBJECT_ID('tempdb.dbo.#DiffBackup') IS NOT NULL DROP TABLE #DiffBackup
	|IF OBJECT_ID('tempdb.dbo.#LogBackup') IS NOT NULL DROP TABLE #LogBackup
	|
	|-- Соберем данные о всех сдаланных раннее бэкапах
	|SELECT
	|	backupset.backup_start_date,
	|	backupset.backup_set_uuid,
	|	backupset.differential_base_guid,
	|	backupset.[type] as btype,
	|	backupmediafamily.physical_device_name
	|INTO #BackupFiles	
	|FROM msdb.dbo.backupset AS backupset
	|	INNER JOIN msdb.dbo.backupmediafamily AS backupmediafamily 
	|	ON backupset.media_set_id = backupmediafamily.media_set_id
	|WHERE backupset.database_name = '" + ПараметрыПодключения.ИмяБазыДанныхSQL + "' 
	|	and backupset.backup_start_date < '" + Формат(ВосстановлениеНаДату,"ДФ='yyyyMMdd ЧЧ:мм:сс'") + "'
	|	and backupset.is_copy_only = 0
	|	and backupset.is_snapshot = 0
	|	and (backupset.description is null or backupset.description not like 'Image-level backup')
	|	and device_type <> 7
	|ORDER BY 
	|	backupset.backup_start_date DESC
	|
	|-- Найдем последний полный бэкап
	|SELECT TOP 1
	|	BackupFiles.backup_start_date,
	|	BackupFiles.physical_device_name,
	|	BackupFiles.backup_set_uuid	
	|INTO #FullBackup	 
	|FROM #BackupFiles AS BackupFiles
	|WHERE btype = 'D'
	|ORDER BY backup_start_date DESC
	|
	|-- Найдем последний разностный бэкап
	|SELECT TOP 1
	|	BackupFiles.backup_start_date,
	|	BackupFiles.physical_device_name
	|INTO #DiffBackup	 
	|FROM #BackupFiles AS BackupFiles
	|	INNER JOIN #FullBackup AS FullBackup
	|	ON BackupFiles.differential_base_guid = FullBackup.backup_set_uuid
	|WHERE BackupFiles.btype = 'I'
	|ORDER BY BackupFiles.backup_start_date DESC
	|
	|-- Соберем бэкапы журналов транзакций
	|SELECT
	|	BackupFiles.backup_start_date,
	|	BackupFiles.physical_device_name
	|INTO #LogBackup	
	|FROM #BackupFiles AS BackupFiles
	|	INNER JOIN
	|	(
	|		SELECT MAX(table_backup_start_date.backup_start_date) AS backup_start_date
	|		FROM 
	|		(
	|			SELECT backup_start_date
	|			FROM #FullBackup
	|			UNION ALL
	|			SELECT backup_start_date
	|			FROM #DiffBackup
	|		) AS table_backup_start_date
	|	) AS table_lsn
	|	ON BackupFiles.backup_start_date > table_lsn.backup_start_date
	|WHERE BackupFiles.btype = 'L'
	|
	|-- Инициируем цикл по объединению всех трех таблиц
	|SELECT physical_device_name
	|FROM 
	|(
	|	SELECT
	|		backup_start_date,
	|		physical_device_name
	|	FROM #FullBackup
	|	UNION ALL
	|	SELECT
	|		backup_start_date,
	|		physical_device_name
	|	FROM #DiffBackup
	|	UNION ALL
	|	SELECT
	|		backup_start_date,
	|		physical_device_name
	|	FROM #LogBackup
	|) AS T 
	|ORDER BY backup_start_date
	|
	|-- Удаляем временные таблицы
	|drop table #BackupFiles
	|drop table #FullBackup
	|drop table #DiffBackup
	|drop table #LogBackup
	|
	|set nocount off
	|";

	Выборка = ВыполнитьЗапрос(ТекстЗапроса,"master",Истина);
	Если Выборка = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МассивФайлов = Новый Массив;
	
	// Заполним таблицу данными файлов
	ВыборкаПрочитана = Ложь;
	Попытка 
		Если Выборка.BOF = Ложь Тогда
			Выборка.MoveFirst();
			Пока Выборка.EOF = Ложь Цикл
				МассивФайлов.Добавить(Выборка.Fields("physical_device_name").Value);
				Выборка.MoveNext();
			КонецЦикла;
		КонецЕсли;
		ВыборкаПрочитана = Истина;
	Исключение
		МассивФайлов.Очистить();
	КонецПопытки;
	
	Если Не ВыборкаПрочитана Тогда
		// Не удолось прочитать данные.
		// Попробуем выгрузить в строку.
		Попытка
			ДанныеВСтроке = СокрЛП(Выборка.GetString(,,Символы.ПС,Символы.ПС));
			Для Сч = 1 По СтрЧислоСтрок(ДанныеВСтроке) Цикл			
				МассивФайлов.Добавить(СокрЛП(СтрПолучитьСтроку(ДанныеВСтроке,Сч)));
			КонецЦикла;
		Исключение
			МассивФайлов.Очистить();
		КонецПопытки;
	КонецЕсли;
	
	Возврат МассивФайлов;
	
КонецФункции

//*****************************************************************
// Переводит базу в режим SINGLE_USER
//
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//
Функция УстановитьМонопольныйРежимДляБД() Экспорт

	ТекстОшибки = "";

	ТекстЗапроса = "
		|-------------------------------------------
		|-- ТЕЛО СКРИПТА
		|ALTER DATABASE [" + ПараметрыПодключения.ИмяБазыДанныхSQL + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;";
	
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции

//*****************************************************************
// Переводит базу в режим MULTI_USER
//
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//
Функция СнятьМонопольныйРежимДляБД() Экспорт

	ТекстОшибки = "";

	ТекстЗапроса = "
		|-------------------------------------------
		|-- ТЕЛО СКРИПТА
		|ALTER DATABASE [" + ПараметрыПодключения.ИмяБазыДанныхSQL + "] SET MULTI_USER;";
	
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции

//*****************************************************************
// Восстанавливает базу данных из параметров подключения по переданным именам файлов
// 
// Параметры:
//		- МассивИменаФайлов - Массив или Строка - Массив имен файлов или имя файла для восстановления. Можно получить из "ПолучитьСписокФайловДляВосстановленияБД"
//		- ТаблицаФайловБДИсточника - ТаблицаЗначений - Таблица файлов БД источника. Можно получить из "ПолучитьСтруктуруФайловБД"
//		- ПереведитьВМонопольныйРежим - Булеов - Флаг того, надо ли переводить базу в монопольный режим перед восстановлением
//
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//	
Функция ВосстановитьИзРезервнойКопииБД(МассивИменаФайлов, ТаблицаФайловБДИсточника="", ПереводитьБДВМонопольныйРежим=Ложь) Экспорт

	ТекстОшибки = "";
	
	// Если передано имя одного файла, добавим его в массив 
	Если ТипЗнч(МассивИменаФайлов) = Тип("Строка") Тогда
		МассивФайлов = Новый Массив;
		МассивФайлов.Добавить(МассивИменаФайлов);
	ИначеЕсли ТипЗнч(МассивИменаФайлов) = Тип("Массив") Тогда
		МассивФайлов = МассивИменаФайлов;
	Иначе
		ТекстОшибки = "Неподходящий тип параметра, переданного в функцию!";
		Возврат Ложь;
	КонецЕсли;
	
	// Проверим, что есть файлы для восстановления
	КоличествоФайлов = МассивФайлов.Количество();
	Если КоличествоФайлов = 0 Тогда
		ТекстОшибки = "Нет файлов для восстановления!";
		Возврат Ложь;
	КонецЕсли;
	
	// Получим массив файлов текущей базы данных
	ТаблицаФайловБД = ПолучитьСтруктуруФайловБД();
	Если ТаблицаФайловБД = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ТекстЗапроса = "
	|-------------------------------------------
	|-- ТЕЛО СКРИПТА
	|";
	
	Для Сч = 0 По КоличествоФайлов-1 Цикл
	
		ТекстЗапроса = ТекстЗапроса + "
		|RESTORE DATABASE [" + ПараметрыПодключения.ИмяБазыДанныхSQL + "]
		|FROM DISK = N'" + МассивФайлов.Получить(Сч) + "' 
		|WITH  
		|FILE = 1, ";
	
		// Добавим замену файлов базы данных (может восстанавливаться из файлов резервных копий другой базы)
		Если ТаблицаФайловБДИсточника = "" Тогда
			Для Каждого ФайлБД Из ТаблицаФайловБД Цикл
				ТекстЗапроса = ТекстЗапроса + "
					|MOVE N'" + ФайлБД.ЛогическоеИмя + "' TO N'" + ФайлБД.ФизическоеИмя + "', ";
			КонецЦикла;
		Иначе
			МинимальноеКоличествоФайлов = Мин(ТаблицаФайловБД.Количество(),ТаблицаФайловБДИсточника.Количество());
			Для СчФайловБД = 0 По МинимальноеКоличествоФайлов-1 Цикл
				ТекстЗапроса = ТекстЗапроса + "
					|MOVE N'" + ТаблицаФайловБДИсточника[СчФайловБД].ЛогическоеИмя + "' TO N'" + ТаблицаФайловБД[СчФайловБД].ФизическоеИмя + "', ";
			КонецЦикла;
		КонецЕсли;
	
		Если Сч = КоличествоФайлов-1 Тогда
			// Это последний файл
			ТекстЗапроса = ТекстЗапроса + "
			|RECOVERY,"
		Иначе
			ТекстЗапроса = ТекстЗапроса + "
			|NORECOVERY,"
		КонецЕсли;
		ТекстЗапроса = ТекстЗапроса + "
		|REPLACE,
		|STATS = 5 
		|";
	
	КонецЦикла;

	Если ПереводитьБДВМонопольныйРежим Тогда
		Если Не УстановитьМонопольныйРежимДляБД() Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ПереводитьБДВМонопольныйРежим Тогда
		Если Не СнятьМонопольныйРежимДляБД() Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;

	Возврат Истина;

КонецФункции

//*****************************************************************
// Восстанавливает базу данных из параметров подключения на указанную дату.
// 
// Параметры:
//		- ВосстановлениеНаДату - Дата - Дата на котороую подбирается последовательность файлов
//			Если не указана, то берется текущая дата.
//
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//	
Функция ВосстановитьБД(ВосстановлениеНаДату = "",ПереводитьБДВМонопольныйРежим=Ложь) Экспорт

	МассивФайлов = ПолучитьСписокФайловДляВосстановленияБД(ВосстановлениеНаДату); 

	Если МассивФайлов = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат ВосстановитьИзРезервнойКопииБД(МассивФайлов,,ПереводитьБДВМонопольныйРежим);

КонецФункции

//*****************************************************************
// Изменяет модель восстановления базы данных из параметров подключения.
//
// Параметры:
//		- МодельВосстановления - Число или Строка - модель восстановления, возможные значения:
//			1 или FULL
//			2 или BULK_LOGGED 
//			3 или SIMPLE
//
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//
Функция ИзменитьМодельВосстановленияБД(Знач МодельВосстановления = "SIMPLE") Экспорт

	ТекстОшибки = "";
	
	// Проверим корректность введенных параметров
	Если Не ПроверитьПараметр("Модель восстановления",МодельВосстановления,"1 | 2 | 3","FULL | BULK_LOGGED | SIMPLE","Строка") Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	ТекстЗапроса = "
		|-------------------------------------------
		|-- ТЕЛО СКРИПТА
		|ALTER DATABASE [" + ПараметрыПодключения.ИмяБазыДанныхSQL + "] SET RECOVERY " + МодельВосстановления + ";";
	
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

//*****************************************************************
// Сжимает базу данных из параметров подключения.
//
// Параметры:
//		- ОставитьПроцентов - Число - Оставить зарезервированное место в %
//		- Обрезать - Число или Строка - Обрезать файл. Возможные значения:
//			0 или NOTRUNCATE 
//			1 или TRUNCATEONLY
// 
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//
Функция СжатьБД(Знач ОставитьПроцентов = "", Знач Обрезать = "") Экспорт

	ТекстОшибки = "";

	// Проверим корректность введенных параметров
	Если Не ПроверитьПараметр("Обрезать",Обрезать,"0 | 1 ","NOTRUNCATE | TRUNCATEONLY","Строка") Тогда 
		Возврат Ложь;
	КонецЕсли;
	Если ОставитьПроцентов = "" Тогда
		ОставитьПроцентов = 0;
	КонецЕсли;
	
	ТекстЗапроса = "
		|-------------------------------------------
		|-- ТЕЛО СКРИПТА
		|DBCC SHRINKDATABASE(N'" + ПараметрыПодключения.ИмяБазыДанныхSQL + "'";
		
	Если ОставитьПроцентов <> 0 Тогда
		ТекстЗапроса = ТекстЗапроса + ", " + ОставитьПроцентов;
	ИначеЕсли Обрезать <> "" Тогда
		ТекстЗапроса = ТекстЗапроса + ", " + Обрезать;
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + ");";
	
	Если ВыполнитьЗапрос(ТекстЗапроса,"master") = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

//*****************************************************************
// Сжимает файлы базы данных из параметров подключения.
//
//	Параметры:
//		- ТипФайла - Число или Строка - Тип файла для сжатия, возможные значения:
//			0 или ROWS - Файл данных
//			1 или LOG - файл жураналов транзакций
//		- ОставитьМб - Число - Число МБ до которого сжимается файл. Если не указан, то сжимается до размера по умолчанию.
//		- Обрезать - Число или Строка - Параметр обрезки файла, возможные значения:
//			1 или TRUNCATEONLY 
//			0 или NOTRUNCATE 
// 
// Возвращает:
//		- Истина - Если запрос выполнен без ошибок
//		- Ложь - Если были ошибки
//
Функция СжатьФайлыБД(Знач ТипФайла = "", ЛогическоеИмяФайла = "", Знач ОставитьМб = "", Знач Обрезать = "") Экспорт

	ТекстОшибки = "";
	
	// Проверим корректность введенных параметров
	Если Не ПроверитьПараметр("Тип файла",ТипФайла,"0 | 1","ROWS | LOG","Число") Тогда 
		Возврат Ложь;
	КонецЕсли;	
	Если Не ПроверитьПараметр("Образать файл",Обрезать,"0 | 1","NOTRUNCATE | TRUNCATEONLY","Строка") Тогда 
		Возврат Ложь;
	КонецЕсли;
	Если ОставитьМб = "" Тогда
		ОставитьМб = 0;
	КонецЕсли;
	
	// Получим массив файлов текущей базы данных
	ТаблицаФайловБД = ПолучитьСтруктуруФайловБД();
	Если ТаблицаФайловБД = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	// Подготовим массив файлов для сжатия, соответствующий заданному отбору
	МассивФайловДляСжатия = Новый Массив;
	Для Каждого ФайлБД Из ТаблицаФайловБД Цикл
		ФайлПодходитПодОтбор = Истина;
		Если ЛогическоеИмяФайла <> "" И
			ЛогическоеИмяФайла <> ФайлБД.ЛогическоеИмя Тогда
			ФайлПодходитПодОтбор = Ложь;
		КонецЕсли;
		Если ТипФайла <> "" И
			ТипФайла <> ФайлБД.Тип Тогда
			ФайлПодходитПодОтбор = Ложь;
		КонецЕсли;
		Если ФайлПодходитПодОтбор Тогда
			МассивФайловДляСжатия.Добавить(ФайлБД.ЛогическоеИмя);
		КонецЕсли;
	КонецЦикла;
	
	// Проверим, есть ли файлы для сжатия
	Если МассивФайловДляСжатия.Количество() = 0 Тогда
		ТекстОшибки = "Нет файлов для сжатия, удовлетворяющих указанному отбору!";
	КонецЕсли;
	
	// Подготовим текст запроса для сжатия файлов
	ТекстЗапроса = "
		|-------------------------------------------
		|-- ТЕЛО СКРИПТА
		|";
	Для Сч=0 По МассивФайловДляСжатия.Количество()-1 Цикл
		
		ТекстЗапроса = ТекстЗапроса + "
			|DBCC SHRINKFILE(N'" + МассивФайловДляСжатия.Получить(Сч) + "'";
		
		Если ОставитьМб <> 0 Тогда
			ТекстЗапроса = ТекстЗапроса + ", " + ОставитьМб;
		ИначеЕсли Обрезать <> "" Тогда
			ТекстЗапроса = ТекстЗапроса + ", " + Обрезать;
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса + ")
			|";
		
	КонецЦикла;
	
	Если ВыполнитьЗапрос(ТекстЗапроса) = Истина Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции	


//*****************************************************************
// Сразу при создании инициируем параметры
ИнициироватьПараметры();










