
--==========================================================================================
-- 1. ��� ����� ��������� ����� �� ������� ������������ �� 1, � ��� ���� ������ ���������� 
--   � ������� Issued (� �� ������� ���������� ��'� � ������� ��������/���������, ����� �����, ���� ������)

create table Issued (
	ID int identity (1, 1) not null primary key,
	first_name nvarchar(50) not null,
	last_name nvarchar(50) not null,		
	book_id int not null,
	book_name nvarchar(50) not null,
	date_out nvarchar(50) not null
);
----------------------------------------------------------------------------------------------------
alter trigger Trigger_One_S on S_Cards	-- ������� �� ������� S_Cards (����� ����� ���������)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		if(select Book.quantity			-- �������� �� � ����� � ��������
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger1 message: this book is absent'
				rollback tran
		   end

		else
		begin
			update 	Book set Book.quantity = Book.quantity - 1			-- ��������� ������� ���������� �����
			from Book inner join Inserted on Book.id = Inserted.id_book
			where Book.id = Inserted.id_book

			insert into Issued (first_name, last_name, book_id, book_name, date_out)	-- ��������� ���������� ��� ������ ����� � ������� Issued
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
alter trigger Trigger_One_T on T_Cards	-- ������� �� ������� T_Cards (����� ����� ����������)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin

		if(select Book.quantity			-- �������� �� � ����� � ��������
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger1 message: this book is absent'
				rollback tran
		   end

		else
		begin
			update 	Book set Book.quantity = Book.quantity - 1			-- ��������� ������� ���������� �����
			from Book inner join Inserted on Book.id = Inserted.id_book
			where Book.id = Inserted.id_book

			insert into Issued (first_name, last_name, book_id, book_name, date_out)	-- ��������� ���������� ��� ������ ����� � ������� Issued
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
-- 2. �������� ������ �����, ��� ��� ���� � ��������

alter trigger Trigger_Two_S on S_Cards	-- ������� �� ������� S_Cards (����� �� �������� �������� ���� ������� 0)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		if(select Book.quantity			-- �������� �� � ����� � ��������
		   from Book inner join Inserted on Book.id = Inserted.id_book
		   where Book.id = Inserted.id_book) = 0
		   begin
				print 'Trigger2 message: this book is absent'
				rollback tran
		   end
	end
end
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Two_T on T_Cards	-- ������� �� ������� T_Cards (����� �� �������� ��������� ���� ������� 0)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin

		if(select Book.quantity			-- �������� �� � ����� � ��������
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
-- 3. ��� ��������� ��������� �����, �� ������� ������������ �� 1, � �� ����������� � ������� Returned

create table Returned (
	ID int identity (1, 1) not null primary key,
	first_name nvarchar(50) not null,
	last_name nvarchar(50) not null,		
	book_id int not null,
	book_name nvarchar(50) not null,
	date_in nvarchar(50) not null
);
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Three_S on S_Cards	-- ������� �� ������� S_Cards (�������� ����� ����������)
for update as
begin	
		declare @temp nvarchar(50) = (select inserted.date_in from inserted)
		if @temp is null		-- �������� �� update ��������� ���� '���� ���������� �����', ���� � - ����� � ��������
		begin
			print 'Trigger_3 doesn''t work!'
			return
		end
		else
		begin
			update 	Book set Book.quantity = Book.quantity + 1			-- ��������� ������� ���������� �����
			from Book inner join Inserted on Book.id = Inserted.id_book

			insert into Returned (first_name, last_name, book_id, book_name, date_in)	-- ��������� ���������� ��� ��������� ����� � ������� Returned
			values
				((select Student.first_name from Student inner join inserted on Student.id = inserted.id_student),
				 (select Student.last_name from Student inner join inserted on Student.id = inserted.id_student),
				 (select inserted.id_book from inserted),
				 (select Book.name from Book inner join inserted on Book.id = inserted.id_book),
				 (select inserted.date_in from inserted))
		end
end
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Three_T on T_Cards	-- ������� �� ������� T_Cards (�������� ����� �����������)
for update as
begin	
		declare @temp nvarchar(50) = (select inserted.date_in from inserted)
		if @temp is null		-- �������� �� update ��������� ���� '���� ���������� �����', ���� � - ����� � ��������
		begin
			print 'Trigger_3 doesn''t work!'
			return
		end
		else
		begin
			update 	Book set Book.quantity = Book.quantity + 1			-- ��������� ������� ���������� �����
			from Book inner join Inserted on Book.id = Inserted.id_book

			insert into Returned (first_name, last_name, book_id, book_name, date_in)	-- ��������� ���������� ��� ��������� ����� � ������� Returned
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
-- 4. �������� ���������� ����� ����, �� �� ���� ��������

create table Book_start (						-- ��������� �������, � ��� ���� ����������� ��������� ������� ����
	ID int identity(1, 1) not null primary key,
	book_id int not null,
	quantity int not null 
);

insert into Book_start (book_id, quantity)		-- ��������� id ���� �� �� ���������� ��������� � �������� �������
select Book.id, Book.quantity from Book

select * from Book_start
----------------------------------------------------------------------------------------------------
alter trigger Trigger_Four on Book
for update as 
begin
	if (select inserted.quantity from inserted) >						-- ���� ������� ������� ���� ����� ���������
	   (select Book_start.quantity from Book_start inner join inserted 
	    on inserted.id = Book_start.book_id)
	begin
		print 'This isn''t our library''s book. It is an extra book'
		rollback tran													-- �� ���������� ����������
	end
end


--==========================================================================================
-- 5. �������� ������ ����� ����� ���� ������ �������� (������ �� ���� ������� ���� �� ����� ��������)

alter trigger Trigger_Five on S_cards
for insert as
begin
	declare @issued_book int = (select count(S_cards.id_student)						-- ��������� ����� - ������� ������� ������ �������� ����
	    from S_Cards inner join inserted on S_Cards.id_student = inserted.id_student	-- �������������: ������� ������� ����
		where S_Cards.id_student = inserted.id_student and (S_Cards.date_in is null)	-- ���� ������� ���������� ����
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
-- 6. ��� �������� ����� ��� ��� �� ���������� � ������� LibDeleted

create table LibDeleted (						-- ��������� �������, � ��� ������ ����������� ������� �����
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
							id_author, id_publishment, comment, quantity)				-- ��������� ����� ��� �������� ����� from Book to LibDeleted
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
-- 7. ���� ���� ����� ������������ � ����, ���� ������� ���� �������� � ������� LibDeleted (���� ���� � �� �)

alter trigger Trigger_Seven on Book
for insert as
begin
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		declare @name nvarchar(100) = (select name from inserted)			-- ���������� � ������ ����� ��� �����, ��� ������������ � ���� �����
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
-- 8. �������� ������ ���� ����� ��������, ���� � ������� ��� �� ����� ����� ����� ���� ������

alter trigger Trigger_Eight on S_Cards
for insert as
begin 
	if @@rowcount = 0 return
	--set nocount on
	else
	begin
		if exists (select * from S_Cards		-- ���� � ������� ������� ���� �� ������ �������� � �������� ������, 
			   where S_Cards.id_student = (select inserted.id_student from inserted))
		begin
			declare @id_student int
			declare @date_out date
			declare @date_in date
			declare student cursor for select S_Cards.id_student, S_Cards.date_out, S_Cards.date_in from S_Cards 	-- ���������� ������� (�� ����� ������ ���� ���� �������)
						   where S_Cards.id_student = (select inserted.id_student from inserted)
			open student;
			fetch next from student into @id_student, @date_out, @date_in;
			while @@fetch_status = 0		-- ������ ����������� �� ������ �� ������ ��������
			begin
				if(@date_in is NULL)		-- ���� ����� �� �� ���������, ��
				begin
					declare @period1 int = convert(int, convert(smalldatetime, getdate(), 101) - convert(smalldatetime, @date_out, 101)) -- ������������� ����� �� ���� ������ �� ������� ����
					if @period1 > 62							-- ���� ��� ����� > 2 ����� (� �������), ��
					begin
						print 'Last time you read a book for more than 2 months. Issuing the book is prohibited'	-- ����� �� ��������
						rollback tran
					end
				end
				else						-- ������: ���� �������� ����� ��������, �� 
				begin
					declare @period2 int = convert(int, convert(smalldatetime, @date_in, 101) - convert(smalldatetime, @date_out, 101))	-- �� ����� ������ ������������� ����� ����������
					if @period2 > 62																									-- ���� ��� ���� ����� ���� ��������� ����� �� ����� 2 �����, ��
					begin
						print 'Last time you read a book for more than 2 months. Issuing the book is prohibited'	-- ����� �� ��������
						rollback tran
					end
				end
				fetch next from student into @id_student, @date_out, @date_in;		-- ������������ ������� � ��������� ����� � ���������� ����� � �������� ����
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
-- 9. ���� �������� ����� ���������, �� �� ������ �� �������� ����� ������ ���� (���� ������ ��������� � � ��������)

alter trigger Trigger_Nine on S_Cards
for insert as
begin 
	if @@rowcount = 0 return
	--set nocount on
	else
	begin
		if ((select Student.first_name 
		    from Student inner join inserted on Student.id = inserted.id_student) like '���������') -- ���� ���������, 
		begin
			if ((select Book.quantity 
				 from Book inner join inserted on Book.id = inserted.id_book) > 0)		-- � ���� ������ � �� ���� ���� � �����,
			begin 
				insert into S_Cards (id_student, id_book, date_out, id_librarian)	-- �� �������� �� ���� ���� � �����
				select id_student, id_book, date_out, id_librarian from inserted
				print 'two books issued'
			end
			else
			begin
				print 'one book issued'												-- ���� ����, �� �� ��������
			end
		end 
	end		
end
----------------------------------------------------------------------------------------------------
/*insert into S_Cards (id_student, id_book, date_out, id_librarian)
values (17, 15, '2023-08-14', 1)*/
--==========================================================================================
-- 10. ���� ���� �����, ��� ���� ����� ��������, ������ ���� ���� ��������� �����, � �������, 
--     ���� ����� � �������� ����� ���������� - ������ ����������� ��� ��

alter trigger Trigger_Ten on T_Cards	-- ������� �� ������� T_Cards (����� ����� ����������)
for insert as
begin	
	if @@rowcount = 0 return
	--set nocount on

	else  
	begin
		
		if(select Book.quantity													-- �������� �� � ����� � ��������
		   from Book inner join Inserted on Book.id = Inserted.id_book) = 0		-- ���� ����� ���� � ��������
		   begin
				print 'Trigger10 message: this book is absent'

				delete from T_Cards												-- ����������� ��� ���������� ����� ��� ������ � T_Cards
				where T_Cards.id_book = (select inserted.id_book from inserted)
				  and T_Cards.date_out = (select inserted.date_out from inserted)

				if (select sum(Book.quantity) from Book) = 0					-- ���� � �������� ������ ������ ����� - �������� �����������
				begin
					print 'There are no any books in the library'
				end
				else															-- ���� ����� �, ��
				begin
					while 1=1
					begin
						declare @row int = round(rand() * (select count(*) from Book), 0)		-- ������������� ��������� ����� (�� ������ �����)

						if (select Temp.quantity												-- �������� �� � �� ��������� ����� � ��������
							from (select row_number() over (order by id) as num, *				
							from Book) as Temp
							where num = @row) > 0

						begin
							insert into T_Cards (id_teacher, id_book, date_out, id_librarian)	-- ���� � - �������� ��������� �����
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
