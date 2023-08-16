
--==========================================================================================
-- 1. При взятті визначеної книги її кількість зменшувалася на 1, а сам факт видачі фіксувався 
--   в таблиці Issued (в неї потрібна записувати ім'я і прізвище студента/викладача, назву книги, дату видачі)

create table Issued (
	ID int identity (1, 1) not null primary key,
	first_name nvarchar(50) not null,
	last_name nvarchar(50) not null,		
	book_id int not null,
	book_name nvarchar(50) not null,
	date_out nvarchar(50) not null
);
----------------------------------------------------------------------------------------------------
alter trigger Trigger_One_S on S_Cards	-- триггер на таблицю S_Cards (видані книги студентам)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		if(select Book.quantity			-- перевірка чи є книга в наявності
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger1 message: this book is absent'
				rollback tran
		   end

		else
		begin
			update 	Book set Book.quantity = Book.quantity - 1			-- зменшення кількості екземплярів книги
			from Book inner join Inserted on Book.id = Inserted.id_book
			where Book.id = Inserted.id_book

			insert into Issued (first_name, last_name, book_id, book_name, date_out)	-- додавання інформації про видану книгу в таблицю Issued
			values
				  ((select Student.first_name from Student inner join inserted on Student.id = inserted.id_student),
				   (select Student.last_name from Student inner join inserted on Student.id = inserted.id_student),
				   (select inserted.id_book from inserted),
				   (select Book.name from Book inner join inserted on Book.id = inserted.id_book),
				   (select inserted.date_out from inserted))

		end
	end
end
----------------------------------------------------------------------------------------------------
alter trigger Trigger_One_T on T_Cards	-- триггер на таблицю T_Cards (видані книги викладачам)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin

		if(select Book.quantity			-- перевірка чи є книга в наявності
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger1 message: this book is absent'
				rollback tran
		   end

		else
		begin
			update 	Book set Book.quantity = Book.quantity - 1			-- зменшення кількості екземплярів книги
			from Book inner join Inserted on Book.id = Inserted.id_book
			where Book.id = Inserted.id_book

			insert into Issued (first_name, last_name, book_id, book_name, date_out)	-- додавання інформації про видану книгу в таблицю Issued
			values
				  ((select Teacher.first_name from Teacher inner join inserted on Teacher.id = inserted.id_teacher),
				   (select Teacher.last_name from Teacher inner join inserted on Teacher.id = inserted.id_teacher),
				   (select inserted.id_book from inserted),
				   (select Book.name from Book inner join inserted on Book.id = inserted.id_book),
				   (select inserted.date_out from inserted))
		end
	end
end
----------------------------------------------------------------------------------------------------

/*insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (3, 4, '2023-08-11', 2)

insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (4, 11, '2023-08-10', 1)

insert into T_Cards (id_teacher, id_book, date_out, id_librarian)
values (5, 10, '2023-08-10', 2)

insert into T_Cards (id_teacher, id_book, date_out, id_librarian)
values (2, 11, '2023-08-10', 1)

update 	Book set Book.quantity = 1
from Book where Book.id = 10

update 	Book set Book.quantity = 1
from Book where Book.id = 11

delete from Issued;*/

--==========================================================================================
-- 2. Заборона видачі книги, якої вже немає в бібліотеці

alter trigger Trigger_Two_S on S_Cards	-- триггер на таблицю S_Cards (книга не видається студенту якщо залишок 0)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		if(select Book.quantity			-- перевірка чи є книга в наявності
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger2 message: this book is absent'
				rollback tran
		   end
	end
end
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Two_T on T_Cards	-- триггер на таблицю T_Cards (книга не видається викладачу якщо залишок 0)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin

		if(select Book.quantity			-- перевірка чи є книга в наявності
		   from Book inner join Inserted on Book.id = Inserted.id_book) = 0
		   --where Book.id = Inserted.id_book) = 0
		   begin
				--select * from inserted
				print 'Trigger2 message: this book is absent'
				rollback tran
		   end
	end
end
----------------------------------------------------------------------------------------------------
--insert into T_Cards (id_teacher, id_book, date_out, id_librarian)
--values (5, 3, '2023-08-12', 2)

--==========================================================================================
-- 3. При поверненні визначеної книги, її кількість збільшувалося на 1, і це фіксувалося в таблиці Returned

create table Returned (
	ID int identity (1, 1) not null primary key,
	first_name nvarchar(50) not null,
	last_name nvarchar(50) not null,		
	book_id int not null,
	book_name nvarchar(50) not null,
	date_in nvarchar(50) not null
);
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Three_S on S_Cards	-- триггер на таблицю S_Cards (повернуті книги студентами)
for update as
begin	
		declare @temp nvarchar(50) = (select inserted.date_in from inserted)
		if @temp is null		-- перевірка чи update стосується поля 'дата повернення книги', якщо ні - вихід з триггера
		begin
			print 'Trigger_3 doesn''t work!'
			return
		end
		else
		begin
			update 	Book set Book.quantity = Book.quantity + 1			-- збільшення кількості екземплярів книги
			from Book inner join Inserted on Book.id = Inserted.id_book

			insert into Returned (first_name, last_name, book_id, book_name, date_in)	-- додавання інформації про повернену книгу в таблицю Returned
			values
				((select Student.first_name from Student inner join inserted on Student.id = inserted.id_student),
				 (select Student.last_name from Student inner join inserted on Student.id = inserted.id_student),
				 (select inserted.id_book from inserted),
				 (select Book.name from Book inner join inserted on Book.id = inserted.id_book),
				 (select inserted.date_in from inserted))
		end
end
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Three_T on T_Cards	-- триггер на таблицю T_Cards (повернуті книги викладачами)
for update as
begin	
		declare @temp nvarchar(50) = (select inserted.date_in from inserted)
		if @temp is null		-- перевірка чи update стосується поля 'дата повернення книги', якщо ні - вихід з триггера
		begin
			print 'Trigger_3 doesn''t work!'
			return
		end
		else
		begin
			update 	Book set Book.quantity = Book.quantity + 1			-- збільшення кількості екземплярів книги
			from Book inner join Inserted on Book.id = Inserted.id_book

			insert into Returned (first_name, last_name, book_id, book_name, date_in)	-- додавання інформації про повернену книгу в таблицю Returned
			values
				((select Teacher.first_name from Teacher inner join inserted on Teacher.id = inserted.id_teacher),
				 (select Teacher.last_name from Teacher inner join inserted on Teacher.id = inserted.id_teacher),
				 (select inserted.id_book from inserted),
				 (select Book.name from Book inner join inserted on Book.id = inserted.id_book),
				 (select inserted.date_in from inserted))
		end
end
----------------------------------------------------------------------------------------------------

/*update S_Cards set id_librarian = 1
from S_Cards where id = 3

update 	T_Cards set date_in = '2023-08-12'
from T_Cards where id = 37

update 	T_Cards set date_in = '2023-08-12'
from T_Cards where id = 31

delete from Returned
where id = 3;*/
--==========================================================================================
-- 4. Заборона повернення більше книг, ніж їх було спочатку

create table Book_start (						-- створення таблиці, в якій буде фіксуватися початкова кількість книг
	ID int identity(1, 1) not null primary key,
	book_id int not null,
	quantity int not null 
);

insert into Book_start (book_id, quantity)		-- копіювання id книг та їх початкових кількостей в стартову таблицю
select Book.id, Book.quantity from Book

select * from Book_start
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Four on Book
for update as 
begin
	if (select inserted.quantity from inserted) >						-- якщо поточна кількість книг більша початкової
	   (select Book_start.quantity from Book_start inner join inserted 
	    on inserted.id = Book_start.book_id)
	begin
		print 'This isn''t our library''s book. It is an extra book'
		rollback tran													-- то транзакція відміняється
	end
end


--==========================================================================================
-- 5. Заборона видачі більше трьох книг одному студенту (мається на увазі кількість книг на руках студента)

alter trigger Trigger_Five on S_cards
for insert as
begin
	declare @issued_book int = (select count(S_cards.id_student)						-- тимчасова змінна - кількість виданих одному студенту книг
	    from S_Cards inner join inserted on S_Cards.id_student = inserted.id_student	-- розраховується: кількість виданих книг
		where S_Cards.id_student = inserted.id_student and (S_Cards.date_in is null)	-- мінус кількість повернених книг
		group by S_Cards.id_student)
	--print '@issued_book = ' + cast(@issued_book as nvarchar(10))

	if @issued_book >= 3
	begin
		print 'Trigger_5: too many books issued to one student!'
		rollback tran
	end
end
----------------------------------------------------------------------------------------------------
/*insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (7, 2, '2023-08-12', 1)

delete from S_Cards where id > 38*/
--==========================================================================================
-- 6. При видаленні книги дані про неї копіювалюся в таблицю LibDeleted

create table LibDeleted (						-- створення таблиці, в якій будуть фіксуватися видалені книги
	ID int not null,
	name nvarchar(100) not null,
	pages int not null,
	year_press int not null,
	id_theme int not null,
	id_category int not null,
	id_author int not null,
	id_publishment int not null,
	comment nvarchar(100),
	quantity int
);
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Six on Book
for delete as
begin
	insert into LibDeleted (ID,	name, pages, year_press, id_theme, id_category,
							id_author, id_publishment, comment, quantity)				-- копіювання даних про видалену книгу from Book to LibDeleted
	select * from deleted

	update LibDeleted
	set LibDeleted.quantity = 0
	from LibDeleted inner join deleted on LibDeleted.ID = deleted.id
end

----------------------------------------------------------------------------------------------------
/*insert into Book (name, pages, year_press, id_theme, id_category,
							id_author, id_publishment, comment, quantity)
values ('Visual Basic', 475, 2005, 2, 11, 14, 5, 'good book', 5)

insert into Book (name, pages, year_press, id_theme, id_category,
							id_author, id_publishment, comment, quantity)
values ('Pascal', 350, 2001, 3, 10, 12, 4, 'old book', 2)

delete from Book where id = 24

select * from LibDeleted*/

--==========================================================================================
-- 7. Якщо нова книга добавляється в базу, вона повинна бути видалена з таблиці LibDeleted (якщо вона в ній є)

alter trigger Trigger_Seven on Book
for insert as
begin
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		declare @name nvarchar(100) = (select name from inserted)			-- фіксування у змінних даних про книгу, яка добавляється в базу даних
		declare @pages int = (select pages from inserted)
		declare @year_press int = (select year_press from inserted)
		declare @id_theme int = (select id_theme from inserted)
		declare @id_category int = (select id_category from inserted)
		declare @id_author int = (select id_author from inserted)
		declare @id_publishment int = (select id_publishment from inserted)
		if exists (select * from LibDeleted 
				   where LibDeleted.name = @name and LibDeleted.pages = @pages and 
				   LibDeleted.year_press = @year_press and LibDeleted.id_theme = @id_theme and
				   LibDeleted.id_category = @id_category and LibDeleted.id_author = @id_author and
				   LibDeleted.id_publishment = @id_publishment)
		begin 
			delete from LibDeleted
			where LibDeleted.name = @name and LibDeleted.pages = @pages and 
				  LibDeleted.year_press = @year_press and LibDeleted.id_theme = @id_theme and
				  LibDeleted.id_category = @id_category and LibDeleted.id_author = @id_author and
				  LibDeleted.id_publishment = @id_publishment
		end
	end	
end
----------------------------------------------------------------------------------------------------
/*insert into Book (name, pages, year_press, id_theme, id_category,
							id_author, id_publishment, comment, quantity)
values ('Visual Basic', 475, 2005, 2, 11, 14, 5, 'good book', 5)

insert into Book (name, pages, year_press, id_theme, id_category,
							id_author, id_publishment, comment, quantity)
values ('Pascal', 350, 2001, 3, 10, 12, 4, 'old book', 2)*/
--==========================================================================================
-- 8. Заборона видачі нової книги студенту, якщо в минулий раз він читав книгу довше двох місяців

alter trigger Trigger_Eight on S_Cards
for insert as
begin 
	if @@rowcount = 0 return
	--set nocount on
	else
	begin
		if exists (select * from S_Cards		-- якщо в таблиці виданих книг по даному студенту є попередні записи, 
			   where S_Cards.id_student = (select inserted.id_student from inserted))
		begin
			declare @id_student int
			declare @date_out date
			declare @date_in date
			declare student cursor for select S_Cards.id_student, S_Cards.date_out, S_Cards.date_in from S_Cards 	-- оголошення курсору (бо таких записів може бути декілька)
						   where S_Cards.id_student = (select inserted.id_student from inserted)
			open student;
			fetch next from student into @id_student, @date_out, @date_in;
			while @@fetch_status = 0		-- будуть перевірятися всі записи по даному студенту
			begin
				if(@date_in is NULL)		-- якщо книга ще не повернута, то
				begin
					declare @period1 int = convert(int, convert(smalldatetime, getdate(), 101) - convert(smalldatetime, @date_out, 101)) -- розраховується період від дати видачі до поточної дати
					if @period1 > 62							-- якщо цей період > 2 місяці (з запасом), то
					begin
						print 'Last time you read a book for more than 2 months. Issuing the book is prohibited'	-- книга не видається
						rollback tran
					end
				end
				else						-- інакше: якщо попередні книги повернуті, то 
				begin
					declare @period2 int = convert(int, convert(smalldatetime, @date_in, 101) - convert(smalldatetime, @date_out, 101))	-- по кожній видачі розраховується термін повернення
					if @period2 > 62																									-- якщо хоч одна книга була повернута більше ніж через 2 місяці, то
					begin
						print 'Last time you read a book for more than 2 months. Issuing the book is prohibited'	-- книга не видається
						rollback tran
					end
				end
				fetch next from student into @id_student, @date_out, @date_in;		-- встановлення курсора в наступний рядок і зчитування даних в тимчасові змінні
			end
			
			close student
			deallocate student
		end 
	end		
end
----------------------------------------------------------------------------------------------------
/*insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (4, 2, '2023-08-14', 1)

update Book
set quantity = 0 where id = 11

update S_Cards
set date_in = '2022-12-10' where id_student = 4*/

--==========================================================================================
-- 9. Якщо студента звати Олександр, то він отримує дві одинакові книги замість одної (якщо другий екземпляр є в наявності)

alter trigger Trigger_Nine on S_Cards
for insert as
begin 
	if @@rowcount = 0 return
	--set nocount on
	else
	begin
		if ((select Student.first_name 
		    from Student inner join inserted on Student.id = inserted.id_student) like 'Александр') -- якщо Олександр, 
		begin
			if ((select Book.quantity 
				 from Book inner join inserted on Book.id = inserted.id_book) > 0)		-- і після видачі є ще одна така ж книга,
			begin 
				insert into S_Cards (id_student, id_book, date_out, id_librarian)	-- то видається ще одна така ж книга
				select id_student, id_book, date_out, id_librarian from inserted
				print 'two books issued'
			end
			else
			begin
				print 'one book issued'												-- якщо немає, то не видається
			end
		end 
	end		
end
----------------------------------------------------------------------------------------------------
/*insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (17, 15, '2023-08-14', 1)*/
--==========================================================================================
-- 10. Якщо немає книги, яку хоче взяти викладач, видати йому одну випадкову книгу, у випадку, 
--     якщо книги в бібліотеці зовсім закінчилися - видати повідомлення про це

alter trigger Trigger_Ten on T_Cards	-- триггер на таблицю T_Cards (видані книги викладачам)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		
		if(select Book.quantity													-- перевірка чи є книга в наявності
		   from Book inner join Inserted on Book.id = Inserted.id_book) = 0		-- якщо книги немає в наявності
		   begin
				print 'Trigger10 message: this book is absent'

				delete from T_Cards												-- видаляється цей вставлений запис про видачу з T_Cards
				where T_Cards.id_book = (select inserted.id_book from inserted)
				  and T_Cards.date_out = (select inserted.date_out from inserted)

				if (select sum(Book.quantity) from Book) = 0					-- якщо в бібліотеці взагалі відсутні книги - видається повідомлення
				begin
					print 'There are no any books in the library'
				end
				else															-- якщо книги є, то
				begin
					while 1=1
					begin
						declare @row int = round(rand() * (select count(*) from Book), 0)		-- розраховується випадкова книга (по номеру рядка)

						if (select Temp.quantity												-- перевірка чи є ця випадкова книга в наявності
							from (select row_number() over (order by id) as num, *				
							from Book) as Temp
							where num = @row) > 0

						begin
							insert into T_Cards (id_teacher, id_book, date_out, id_librarian)	-- якщо є - видається випадкова книга
							values ((select inserted.id_teacher from inserted), 
									(select Temp.id from (select row_number() over (order by id) as num, *				
																from Book) as Temp where num = @row),
									(select inserted.date_out from inserted),
									(select inserted.id_librarian from inserted))
							break
						end
					end				
				end
		   end
	end
end
----------------------------------------------------------------------------------------------------
/*insert into T_Cards (id_teacher, id_book, date_out, id_librarian)
values (5, 10, '2023-08-15', 2)

update Book
set quantity = 0 */
--==========================================================================================
