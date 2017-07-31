﻿
// На входе имя веб-сервиса, на выходе markdown
//
// Возвращаемое значение:
//   ТекстовыйДокумент
//
Функция ПолучитьРазметку(Знач ИмяВебСервиса) Экспорт

	МетаданныеСервиса = Метаданные.WebСервисы.Найти(ИмяВебСервиса);
	Если МетаданныеСервиса = Неопределено Тогда
		ВызватьИсключение "Не найден веб-сервис с именем " + ИмяВебСервиса;
	КонецЕсли;
	
	Документ = Новый ТекстовыйДокумент;
	ВывестиЗаголовок(МетаданныеСервиса, Документ);
	ВывестиОперацииСервиса(МетаданныеСервиса, Документ);
	ВывестиТипыСхемXML(МетаданныеСервиса, Документ);
	
	Возврат Документ;
	
КонецФункции // ПолучитьРазметку()

Процедура ВывестиЗаголовок(Знач МетаданныеСервиса, Знач Документ)
	
	Заголовок(Документ, "#", МетаданныеСервиса.Синоним);
		
	Документ.ДобавитьСтроку(МетаданныеСервиса.ПространствоИмен);
	Отступ(Документ);
	
КонецПроцедуры

Процедура ВывестиОперацииСервиса(Знач МетаданныеСервиса, Знач Документ)
	
	Заголовок(Документ, "##", "Операции");
	
	Для Каждого Операция Из МетаданныеСервиса.Операции Цикл
		ВывестиОперацию(МетаданныеСервиса, Операция, Документ);
	КонецЦикла;
	
КонецПроцедуры

Процедура ВывестиОперацию(Знач МетаданныеСервиса, Знач Операция, Знач Документ)
	
	Заголовок(Документ, "####", Операция.Имя);
	
	Если Не ПустаяСтрока(Операция.Комментарий) Тогда
		Документ.ДобавитьСтроку(Операция.Комментарий);
		Отступ(Документ);
	КонецЕсли;
	
	Если Операция.Параметры.Количество() > 0 Тогда
		
		Заголовок(Документ, "####", "Параметры");
		
		ТаблицаПараметров = Новый ТаблицаЗначений;
		ТаблицаПараметров.Колонки.Добавить("Имя");
		ТаблицаПараметров.Колонки.Добавить("Тип");
		ТаблицаПараметров.Колонки.Добавить("Направление");
		ТаблицаПараметров.Колонки.Добавить("Описание");
		
		Для Каждого Параметр Из Операция.Параметры Цикл
			Стр = ТаблицаПараметров.Добавить();
			Стр.Имя = Параметр.Имя;
			Стр.Тип = Параметр.ТипЗначенияXDTO;
			Стр.Направление = Параметр.НаправлениеПередачи;
		КонецЦикла;
		
		Таблица(Документ, ТаблицаПараметров);
		
	КонецЕсли;
	
	Заголовок(Документ, "####", "Возвращаемое значение");
	
	Документ.ДобавитьСтроку(Операция.ТипВозвращаемогоЗначенияXDTO);
	Отступ(Документ);
	
КонецПроцедуры

Процедура ВывестиТипыСхемXML(Знач МетаданныеСервиса, Знач Документ)
	
	Заголовок(Документ, "#", "Описание типов данных");
	
	// из-за ошибки платформы нельзя перебрать пакеты сервиса напрямую
	// поэтому придется искать их обходным путем.
	ПакетыСервиса = ОпределитьПакетыСервиса(МетаданныеСервиса);
	
	Для Каждого Пакет Из ПакетыСервиса Цикл
		Заголовок(Документ, "##", ИмяПакетаВМетаданных(Пакет));
		Документ.ДобавитьСтроку(Пакет.URIПространстваИмен);
		
		ПростыеТипы   = Новый Массив;
		ОбъектныеТипы = Новый Массив;
		
		Для Каждого ТипXDTO Из Пакет Цикл
			Если ТипЗнч(ТипXDTO) = Тип("ТипЗначенияXDTO") Тогда
				ПростыеТипы.Добавить(ТипXDTO);
			Иначе
				ОбъектныеТипы.Добавить(ТипXDTO);
			КонецЕсли;
		КонецЦикла;
		
		ВывестиПростыеТипы(Документ, ПростыеТипы);
		ВывестиОбъектныеТипы(Документ, ОбъектныеТипы);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ИмяПакетаВМетаданных(Знач Пакет)
	Для Каждого Мета Из Метаданные.ПакетыXDTO Цикл
		Если Мета.ПространствоИмен = Пакет.URIПространстваИмен Тогда
			Возврат Мета;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
КонецФункции

Функция ОпределитьПакетыСервиса(Знач МетаданныеСервиса)
	
	УпоминаемыеПакеты = Новый Соответствие;
	Для Каждого Операция Из МетаданныеСервиса.Операции Цикл
		УпоминаемыеПакеты.Вставить(Операция.ТипВозвращаемогоЗначенияXDTO.URIПространстваИмен, Истина);
		Для Каждого Параметр Из Операция.Параметры Цикл
			УпоминаемыеПакеты.Вставить(Параметр.ТипЗначенияXDTO.URIПространстваИмен, Истина);
		КонецЦикла;
	КонецЦикла;
	
	ИмяСтандартнойСхемы = "http://www.w3.org/2001/XMLSchema";
	УпоминаемыеПакеты.Удалить(ИмяСтандартнойСхемы);
	
	МассивУникальных = Новый Массив;
	Для Каждого КлючИЗначение Из УпоминаемыеПакеты Цикл
		МассивУникальных.Добавить(КлючИЗначение.Ключ);
	КонецЦикла;
	
	ПакетыСервиса = Новый Соответствие;
	Для Каждого ПространствоПакета Из МассивУникальных Цикл
		Пакет = ФабрикаXDTO.Пакеты.Получить(ПространствоПакета);
		ПакетыСервиса.Вставить(ПространствоПакета, Пакет);
		ДобавитьЗависимостиПакетаXDTO(Пакет, ПакетыСервиса);
	КонецЦикла;
	
	МассивПакетов = Новый Массив;
	Для Каждого КлючИЗначение Из ПакетыСервиса Цикл
		МассивПакетов.Добавить(КлючИЗначение.Значение);
	КонецЦикла;
	
	Возврат МассивПакетов;
	
КонецФункции

Процедура ДобавитьЗависимостиПакетаXDTO(Знач Пакет, Знач ПакетыСервиса)
	
	ИмяСтандартнойСхемы = "http://www.w3.org/2001/XMLSchema";
	
	Для Каждого Зависимость Из Пакет.Зависимости Цикл
		Если Зависимость.URIПространстваИмен <> ИмяСтандартнойСхемы
			 и ПакетыСервиса[Зависимость.URIПространстваИмен] = Неопределено Тогда
			 
			ПакетыСервиса.Вставить(Зависимость.URIПространстваИмен, Зависимость);
			ДобавитьЗависимостиПакетаXDTO(Зависимость, ПакетыСервиса);			
			
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ВывестиПростыеТипы(Знач Документ, Знач Типы)
	
	Заголовок(Документ, "###", "Простые типы");
	
	ТаблицаТипов = Новый ТаблицаЗначений;
	ТаблицаТипов.Колонки.Добавить("Имя");
	ТаблицаТипов.Колонки.Добавить("БазовыйТип",,"Базовый тип");
	ТаблицаТипов.Колонки.Добавить("Описание");
	
	Для Каждого ТипЗначения Из Типы Цикл
		
		Стр = ТаблицаТипов.Добавить();
		Стр.Имя = ТипЗначения.Имя;
		Стр.БазовыйТип = ТипЗначения.БазовыйТип; 
		
	КонецЦикла;
	
	Таблица(Документ, ТаблицаТипов);
	
КонецПроцедуры

Процедура ВывестиОбъектныеТипы(Знач Документ, Знач ОбъектныеТипы)
	
	Для Каждого ТипОбъекта Из ОбъектныеТипы Цикл
		
		Заголовок(Документ, "###", ТипОбъекта.Имя);
		
		Если ТипОбъекта.БазовыйТип.Имя <> "anyType" Тогда
			Документ.ДобавитьСтроку("Базовый тип: " + ТипОбъекта.БазовыйТип);
			Отступ(Документ);
		КонецЕсли;
		
		Заголовок(Документ, "####", "Свойства");
		
		ТаблицаСвойств = Новый ТаблицаЗначений;
		ТаблицаСвойств.Колонки.Добавить("Имя");
		ТаблицаСвойств.Колонки.Добавить("Тип");
		ТаблицаСвойств.Колонки.Добавить("Повторяемость");
		ТаблицаСвойств.Колонки.Добавить("Описание");
		
		Для Каждого Свойство Из ТипОбъекта.Свойства Цикл
			Стр = ТаблицаСвойств.Добавить();
			Стр.Имя = Свойство.Имя;
			Стр.Тип = Свойство.Тип;
			Стр.Повторяемость = "[ " + Свойство.НижняяГраница + "..." + Свойство.ВерхняяГраница + " ]";
		КонецЦикла;
		
		Таблица(Документ, ТаблицаСвойств);
		
	КонецЦикла;
	
КонецПроцедуры


////////////////////////////////////////////////

Процедура Заголовок(Знач Документ, Знач Префикс, Знач Текст)
	Документ.ДобавитьСтроку(Префикс + " " + Текст);
	Отступ(Документ);
КонецПроцедуры

Процедура Отступ(Знач Документ)
	Документ.ДобавитьСтроку("");
КонецПроцедуры

Процедура Таблица(Знач Документ, Знач ТаблицаЗначений)
	
	ЗаголовокТаблицы = "";
	Отчерк = "";
	Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		ЗаголовокТаблицы = ЗаголовокТаблицы + "|" + ?(ПустаяСтрока(Колонка.Заголовок),Колонка.Имя,Колонка.Заголовок);
		Отчерк = Отчерк + "|-";
	КонецЦикла;
	
	Документ.ДобавитьСтроку(ЗаголовокТаблицы);
	Документ.ДобавитьСтроку(Отчерк);
	
	Для Каждого СтрокаТаблицы Из ТаблицаЗначений Цикл
		
		ДанныеСтроки = "";
		Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
			ДанныеСтроки = ДанныеСтроки + "|" + СтрокаТаблицы[Колонка.Имя];
		КонецЦикла;
		
		Документ.ДобавитьСтроку(ДанныеСтроки);
		
	КонецЦикла;
	
	Отступ(Документ);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////
// Методы HTML-визуализации

Функция ПолучитьФорматированныйДокумент(Знач Разметка, Знач Стиль) Экспорт
	
	Шаблон   = ПолучитьМакет("Документ").ПолучитьТекст();
	Документ = СтрЗаменить(Шаблон,"%STYLE", Стиль);
	Документ = СтрЗаменить(Документ,"%SOURCE", Разметка);
	
	Возврат Документ;
		
КонецФункции
