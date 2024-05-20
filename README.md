# USB2KBD (COM) type wall of text
Perl скрипт который получает стену текста в stdin, конвертирует символы в кейкоды usb2kbd эмулятора клавиатуры и посылает комманды на впечатывание текста с задержками

Скрипт тестировался в linux и будет использоваться в linux, соответственно за винду я не отвечаю, но думаю что в cygwin все должно работать ок.
# Зачем?
Потому что VNC. Никогда в нем не работает нормально буфер обмена. А у VNC интерфейса виртуальной машины его впринципе быть не должно. В таком случае впечатывание текста отличный компромисс, и раньше в иксах это работало нормально (гдето в районе убунты 18.04), но потом соевые фанаты поттеринга обновили что-то и в xvkbd перестал вообще работать ключ -xsendevent, а без него xvkbd сжирает буквы или даже целые слова. На дебиане тоже самое, т.е. дело в самих иксах.

# Необходимое оборудование
https://usb2kbd.ru/25-usb2kbd_lan.html, но используется через COM, если нужно UDP то переписать под UDP должно быть легко.

# Важная информация
В скрипте должна быть адекватная задержка (у меня это 20мс), или VNC может сожрать буквы. Также необходима более большая задержка (200мс) в самом начале, иначе сожрется первая буква. Не знаю почему это происходит, но если использовать такие задержки и "активировать" ввод вначале моим методом отжима кнопок, то все работает ок.

# Использование для вставки буфера обмена
1. Качаем perl-скрипт, убеждаемся что он работает, с помощью 
`echo Test | sudo perl type.pl`
2. Качаем bash-скрипт "clip", устанавливаем xsel если его нет, указываем путь к перл скрипту, делаем chmod +x 
3. Задаем хоткей в вашем desktop environment который будет запускать скрипт clip, у меня это обычно ctrl+alt+v
4. Радуемся тому, что больше не нужно перебрасывать текстовые файлы через 10 жоп

# Кириллица
Скрипт может печатать и по русски, только за выставление правильной раскладки перед запуском отвечаете вы сами. Перед запуском печати скрипт проверяет есть ли в вводных данных хоть одна кириллическая буква, если есть то включается режим кириллицы. Скрипт не умеет переключаться через Alt+Shift. Символы которых в раскладке нет - будут пропущены.

# Бонус
Скрипт qr для сканирования qr кодов с экрана (таким образом можно забирать текстовые данные из виртуалок без буфера обмена)
