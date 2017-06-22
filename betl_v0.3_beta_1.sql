USE [master]
GO
/****** Object:  Database [BETL]    Script Date: 22-6-2017 10:10:00 ******/
CREATE DATABASE [BETL]
GO
USE [BETL]
GO
/****** Object:  Schema [column]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [column]
GO
/****** Object:  Schema [def]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [def]
GO
/****** Object:  Schema [his]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [his]
GO
/****** Object:  Schema [meta]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [meta]
GO
/****** Object:  Schema [process]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [process]
GO
/****** Object:  Schema [tmp]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [tmp]
GO
/****** Object:  Schema [util]    Script Date: 22-6-2017 10:10:00 ******/
CREATE SCHEMA [util]
GO
/****** Object:  UserDefinedTableType [dbo].[ColumnTable]    Script Date: 22-6-2017 10:10:00 ******/
CREATE TYPE [dbo].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_name] [varchar](64) NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedTableType [dbo].[MappingTable]    Script Date: 22-6-2017 10:10:00 ******/
CREATE TYPE [dbo].[MappingTable] AS TABLE(
	[src_id] [int] NOT NULL,
	[trg_id] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[src_id] ASC,
	[trg_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedTableType [dbo].[ParamTable]    Script Date: 22-6-2017 10:10:00 ******/
CREATE TYPE [dbo].[ParamTable] AS TABLE(
	[param_name] [varchar](255) NOT NULL,
	[param_value] [sql_variant] NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedTableType [dbo].[SplitList]    Script Date: 22-6-2017 10:10:00 ******/
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](8000) NULL,
	[i] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [def].[ColumnTable]    Script Date: 22-6-2017 10:10:00 ******/
CREATE TYPE [def].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_name] [varchar](64) NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedFunction [def].[const]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2015-08-31
-- Description:	returns int value for const string. 
-- this way we don't have to use ints foreign keys in our code. 
-- Assumption: const is unique across all lookup tables. 
-- Lookup tables: Object_type
-- =============================================
--select def.const('table')
CREATE FUNCTION [def].[const]
(
	@const varchar(255) 
)
RETURNS int 
AS
BEGIN
	declare @res as int 
	SELECT @res = object_type_id from def.object_type 
	where object_type = @const 
	
	RETURN @res

END







GO
/****** Object:  UserDefinedFunction [def].[get_cols]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- =============================================
-- returns a table with all column meta data 
-- Unfortunately we have to re-define the columTable type here... 
-- see http://stackoverflow.com/questions/2501324/can-t-sql-function-return-user-defined-table-type

CREATE FUNCTION [def].[get_cols]
(
	@object_id int
)
RETURNS @cols TABLE(
	[ordinal_position] [int] NOT NULL PRIMARY KEY,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreignCol_name] [varchar](64) NULL,
	[foreign_sur_pkey] int NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	part_of_unique_index BIT NULL,
	[identity] [bit] NULL

)  as
begin 
	--SET IDENTITY_INSERT @cols ON 
	insert into @cols(
		ordinal_position
		, column_name
		, column_value
		, data_type 
		, max_len
		, [column_type_id] 
		, is_nullable
		, [prefix] 
		, [entity_name]
		, [foreignCol_name] 
		, [foreign_sur_pkey] 
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,part_of_unique_index 
		  ,[identity]
		) 
		select 
			ordinal_position
			, column_name
			, null column_value
			, data_type 
			, max_len
			, [column_type_id] 
			, is_nullable
			, prefix
			, [entity_name]
			, [foreign_column_name]
			, [foreign_sur_pkey] 
			  ,[numeric_precision]
			  ,[numeric_scale]
			  ,part_of_unique_index 
			  ,null [identity]
		from def.Col_ext
		where [object_id] = @object_id 
	--SET IDENTITY_INSERT @cols OFF
	RETURN
end


--SELECT * from vwCol




GO
/****** Object:  UserDefinedFunction [def].[get_prop]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- select  def.get_prop('use_linked_server' , 'C2H_PC')

CREATE function [def].[get_prop] (
	@prop varchar(255)
	, @fullObj_name varchar(255) 
	, @scope as varchar(255) = null 
	)
returns varchar(255) 

as 
begin
	declare @obj_id as int 
	Set @obj_id = def.object_id(@fullObj_name, @scope) 
	return def.get_prop_obj_id(@prop, @obj_id) 
end







GO
/****** Object:  UserDefinedFunction [def].[get_prop_obj_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- select  def.get_prop('etl_meta_fields' , 'idv', null)

CREATE function [def].[get_prop_obj_id] (
	@prop varchar(255)
	, @obj_id int = null 
	)
returns varchar(255) 

as 
begin
	-- standard BETL header code... 
	--set nocount on 
	declare   @res as varchar(255) 
--			, @debug as bit =0
			, @progress as bit =0
	--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec def.get_var 'debug', @debug output
	--exec def.get_var 'progress', @progress output
	--exec progress @progress, '? ?', @proc_name , @fullObj_name
	-- END standard BETL header code... 
	--return def.get_prop_obj_id @obj_id 

	--exec progress @progress, 'obj_id ?', @obj_id 
	;
	with q as ( 
	select o.object_id, o.object_name, p.property, p.value, p.default_value,
	case when p.[object_id] = o.[object_id] then 0 
		when p.[object_id] = o.parent_id then 1 
		when p.[object_id] = o.grand_parent_id then 2 
		when p.[object_id] = o.great_grand_parent_id then 3 end moved_up_in_hierarchy
	from def.prop_ext p 
	left join def.obj_ext o on 
		p.[object_id] = o.[object_id] 
		or p.[object_id] = o.parent_id
		or p.[object_id] = o.grand_parent_id
		or p.[object_id] = o.great_grand_parent_id
	where property = @prop
	and o.[object_id] = @obj_id 
	) 
	, q2 as ( 
	select *, row_number() over (partition by [object_id] order by moved_up_in_hierarchy asc) seq_nr 
	 from q 
	 where value is not null 
	) 
	select --* 
	@res= isnull(value , default_value) 
	from q2 
	where seq_nr = 1

	return @res

end







GO
/****** Object:  UserDefinedFunction [def].[guess_entity_name]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.[guess_entity_name]('par_relatie_id')
-- SELECT def.[guess_entity_name]('relatie_id')
-- SELECT def.[guess_entity_name]('child_relatie_id')

CREATE FUNCTION [def].[guess_entity_name]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,	@foreignCol_id int
	
	SELECT @foreignCol_id  = def.guess_foreignCol_id( @column_name) 

	SELECT @res = [object_name]
	FROM def.Col c
	INNER JOIN [def].[Obj] obj ON obj.object_id = c.object_id
	WHERE column_id = @foreignCol_id  

	RETURN @res 
END




GO
/****** Object:  UserDefinedFunction [def].[guess_foreignCol_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreignCol_id('par_relatie_id')
-- SELECT def.guess_foreignCol_id('relatie_id')
-- SELECT def.guess_foreignCol_id('dienstverband_id')

CREATE FUNCTION [def].[guess_foreignCol_id]( @column_name VARCHAR(255) ) 

RETURNS int
AS
BEGIN
	DECLARE @nat_keys AS TABLE ( 
		column_id  int 
		, column_name  varchar(255) 
		, object_name  varchar(255) 
	) 

	INSERT INTO @nat_keys 

	SELECT c.column_id, c.column_name, o.[object_name] -- , COUNT(*) cnt
	FROM def.Col c
	INNER JOIN def.Obj o ON c.object_id = o.object_id
	INNER JOIN def.Col c2 ON c.object_id = c2.object_id -- AND c2.column_id <> c.column_id 
	WHERE 
	c.column_type_id = 100 -- nat_pkey 
	AND c2.column_type_id = 100 
	AND c2.column_name NOT IN ( 'etl_data_source', 'etl_load_dts') 
	GROUP BY 
	c.column_id, c.column_name, o.[object_name]
	HAVING COUNT(*) = 1 


	DECLARE @res INT 
	,		@pos INT 

	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM @nat_keys 
	WHERE column_name = @column_name
	AND def.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub

	SET @pos = CHARINDEX('_', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)

		SELECT @res = MAX(column_id) -- for now take the last known column if >1 
		FROM @nat_keys 
		WHERE column_name = @remove_prefix
		AND def.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub
	end

	-- Return the result of the function
	RETURN @res 
END




GO
/****** Object:  UserDefinedFunction [def].[guess_prefix]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_prefix('par_relatie_id')
-- SELECT def.guess_prefix('relatie_id')
CREATE FUNCTION [def].[guess_prefix]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @res INT 
	,		@pos INT 
	, @prefix VARCHAR(64)=''

	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM def.Col c
	INNER JOIN def.[Obj] o ON o.[object_id] = c.[object_id]
	WHERE column_name = @column_name
	AND column_type_id = 100 -- nat_pkey
	AND def.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub
	/* 
	declare @column_name VARCHAR(255)  = 'par_relatie_id'
	,		@pos INT 
	 SELECT CHARINDEX('_', @column_name )
	 SET @pos = CHARINDEX('_', @column_name)
	 select SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
	 */
	SET @pos = CHARINDEX('_', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
		SET @prefix = SUBSTRING(@column_name, 1, @pos-1)

		SELECT @res = MAX(column_id) -- for now take the last known column if >1 
		FROM def.Col c
		INNER JOIN def.[Obj] o ON o.[object_id] = c.[object_id]
		WHERE column_name = @remove_prefix
		AND column_type_id = 100 -- nat_pkey
		AND def.prefix_first_underscore([object_name]) ='hub'
	end

	-- Return the result of the function
	RETURN @prefix
END




GO
/****** Object:  UserDefinedFunction [def].[object_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--select def.object('C2H_PC.AdventureWorks2014.Person.Person') --> points to table 
--select def.object('C2H_PC.AdventureWorks2014.Person') --> points to schema
--select def.object('C2H_PC.AdventureWorks2014') --> points to db
--select def.object('C2H_PC.BETL') --> points to db
--select def.object('C2H_PC') --> points to srv
--select def.object('C2H_PC.def') 
--select def.object('def') 

CREATE FUNCTION [def].[object_id]( @fullObj_name varchar(255) , @scope varchar(255) = null ) 
RETURNS int
AS
BEGIN
	-- standard BETL header code... 
	--set nocount on 
	--declare   @debug as bit =1
	--		, @progress as bit =1
	--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec def.get_var 'debug', @debug output
	--exec def.get_var 'progress', @progress output
	--exec progress @progress, '? ?,?', @proc_name , @fullObj_name

	-- END standard BETL header code... 

	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	select @object_id= max(o.object_id), @cnt = count(*) 
	from def.[Obj] o
	LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where o.[object_name] = @elem1 
	and ( @elem2 is null or parent_o.[object_name] = @elem2 ) 
	and ( @elem3 is null or grand_parent_o.[object_name] = @elem3) 
	and ( @elem4 is null or great_grand_parent_o.[object_name] = @elem4) 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			or o.object_type_id= 50 -- scope not relevant for servers. 
		)  
	and o.delete_dt is null 

	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@object_id 
	return @res 
END





GO
/****** Object:  UserDefinedFunction [def].[schema_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema_id of this full object name 
--  e.g. LOCALHOST.AdventureWorks2014.Person.Sales ->LOCALHOST.AdventureWorks2014.Person
-- =============================================

--select def.object('LOCALHOST.AdventureWorks2014.Person.Sales') --> points to table 
--select def.object('LOCALHOST.AdventureWorks2014.Person') --> points to schema
--select def.object('LOCALHOST.AdventureWorks2014') --> points to db
--select def.object('LOCALHOST.BETL') --> points to db
--select def.object('LOCALHOST') --> points to srv
--select def.object('LOCALHOST.def') 
--select def.object('def') 

CREATE FUNCTION [def].[schema_id]( @fullObj_name varchar(255), @scope varchar(255) = null  ) 
RETURNS int
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
--exec def.get_var 'debug', @debug output
--exec def.get_var 'progress', @progress output
--exec progress @progress, '? ?,?', @proc_name , @fullObj_name

-- END standard BETL header code... 

	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

		 
	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	select @object_id= max(o.object_id), @cnt = count(*) 
	from def.[Obj] o
	LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where 	o.[object_name] = @elem2
	and ( @elem3 is null or parent_o.[object_name] = @elem3) 
	and ( @elem4 is null or grand_parent_o.[object_name] = @elem4) 
	and ( @scope is null or 
			@scope = o.scope
			or @scope = parent_o.scope
			or @scope = grand_parent_o.scope
			or @scope = great_grand_parent_o.scope) 

	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@object_id 
	return @res 
END








GO
/****** Object:  UserDefinedFunction [def].[schema_name]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema name of this full object name 
--  e.g. C2H_PC.AdventureWorks2014.Person.Sales ->C2H_PC.AdventureWorks2014.Person
-- =============================================

--select def.schema('C2H_PC.AdventureWorks2014.Person.Sales') --> points to table 

CREATE FUNCTION [def].[schema_name]( @fullObj_name varchar(255) , @scope varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @schema_id as int 
		, @res as varchar(255) =''
		select @schema_id = def.schema_id(@fullObj_name, @scope ) 


	select @res = [full_object_name] --isnull('['+ srv + '].', '') +  isnull('['+db +'].','') + '['+ [schema] + ']'
	from def.obj_ext 
	where [object_id] = @schema_id



	return @res 
END








GO
/****** Object:  UserDefinedFunction [def].[template_name]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- select def.[template_name](300) 
CREATE FUNCTION [def].[template_name]
(
	@template_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @template_name as varchar(255) 
	select @template_name = [content_type_name] from def.Content_type where content_type_id = @template_id 
	return @template_name + ' (' + convert(varchar(10), @template_id ) + ')'

END




GO
/****** Object:  UserDefinedFunction [util].[addQuotes]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [util].[addQuotes]
(
	@s varchar(7900) 
)
RETURNS varchar(8000) 
AS
BEGIN
	RETURN '''' + isnull(@s , '') + '''' 
END








GO
/****** Object:  UserDefinedFunction [util].[Int2Char]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [util].[Int2Char] (     @i int)
RETURNS varchar(15) AS
BEGIN
       RETURN isnull(convert(varchar(15), @i), '')
END








GO
/****** Object:  UserDefinedFunction [util].[object_name]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema name of this full object name 
--  e.g. C2H_PC.AdventureWorks2014.Person.Sales ->C2H_PC.AdventureWorks2014.Person
-- =============================================

--select def.object_name('C2H_PC.AdventureWorks2014.Person.Sales') --> points to table 

CREATE FUNCTION [util].[object_name]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
--exec def.get_var 'debug', @debug output
--exec def.get_var 'progress', @progress output
--exec progress @progress, '? ?,?', @proc_name , @fullObj_name

-- END standard BETL header code... 

	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

		 
	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	--select @object_id= max(o.object_id), @cnt = count(*) 
	--from def.[Obj] o
	--LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	--LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	--LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	--where 	o.[object_name] = @elem2
	--and ( @elem3 is null or parent_o.[object_name] = @elem3) 
	--and ( @elem4 is null or grand_parent_o.[object_name] = @elem4) 
	declare @res as varchar(255) 
	--if @cnt >1 
	--	set @res =  -@cnt
	--else 
	--	set @res =@object_id 

	set @res = '[' + @elem1 + ']'
	return @res 
END








GO
/****** Object:  UserDefinedFunction [util].[parent]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- returns parent by parsing the string. e.g. localhost.AdventureWorks2014.def = localhost.AdventureWorks2014
-- select def.parent('localhost.AdventureWorks2014.def')
CREATE FUNCTION [util].[parent]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @rev_str as varchar(255) 
			, @i as int
			, @res as varchar(255) 
	set @rev_str = reverse(@fullObj_name ) 
	set @i = charindex('.', @rev_str) 
	
	if @i = 0 
		set @res = null 
	else 
		set @res =  substring( @fullObj_name, 1, len( @fullObj_name) - @i ) 
	return @res 
END








GO
/****** Object:  UserDefinedFunction [util].[prefix]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:                            <Author,,Name>
-- Create date: 2017-01-01
-- Description:    returns true if @s ends with @suffix
-- =============================================
--select def.prefix('gfjhaaaaa_aap', 4) 

CREATE FUNCTION [util].[prefix]
(
                @s as varchar(255)
                , @len_suffix as int
                --, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
                declare @n as int=len(@s) 
                                                --, @n_suffix as int = len(@suffix)

                declare @result as bit = 0 
                return SUBSTRING(@s, 1, @n-@len_suffix) 
END







GO
/****** Object:  UserDefinedFunction [util].[prefix_first_underscore]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreignCol_id('par_relatie_id')
-- SELECT [def].[prefix_first_underscore]('relatie_id')
-- DROP FUNCTION [def].[prefix_underscore]

CREATE FUNCTION [util].[prefix_first_underscore]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,		@pos INT 

	SET @pos = CHARINDEX('_', @column_name)

	IF @pos IS NOT NULL and @pos>1
		SET @res = SUBSTRING(@column_name, 1, @pos-1)

	RETURN @res 
	/* 
		declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, 1, @n-@len_suffix) 
	*/
END





GO
/****** Object:  UserDefinedFunction [util].[split]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- --CREATE TYPE SplitListType AS TABLE 	(item VARCHAR(8000), i int)
-- select * from util.split('AAP,NOOT', ',')
CREATE  FUNCTION [util].[split](
    @sInputList VARCHAR(8000) -- List of delimited items
  , @sDelimiter VARCHAR(16) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item VARCHAR(8000), i int)

BEGIN
DECLARE @sItem VARCHAR(8000)
, @i int =1


WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
 BEGIN
 SELECT
  @sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
  @sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
 IF LEN(@sItem) > 0
 begin
  INSERT INTO @List SELECT @sItem, @i
  set @i += 1
 end 
  
 END

IF LEN(@sInputList) > 0
 INSERT INTO @List SELECT @sInputList , @i-- Put the last item in
RETURN
END











GO
/****** Object:  UserDefinedFunction [util].[suffix]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	returns true if @s ends with @suffix
-- =============================================
--select def.suffix('gfjh_aap', '_aap') 
--select def.suffix('gfjh_aap', 4) 
--select def.suffix('gfjh_aap', '_a3p') 

CREATE FUNCTION [util].[suffix]
(
	@s as varchar(255)
	, @len_suffix as int
	--, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, @n+1-@len_suffix, @len_suffix) 
END








GO
/****** Object:  UserDefinedFunction [util].[suffix_first_underscore]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreignCol_id('par_relatie_id')
-- SELECT [def].[suffix_first_underscore]('relatie_id')
-- DROP FUNCTION [def].[prefix_underscore]

CREATE FUNCTION [util].[suffix_first_underscore]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,		@pos INT 

	SET @pos = CHARINDEX('_', @column_name)

	IF @pos IS NOT NULL
		SET @res = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)

	RETURN @res 
	/* 
		declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, 1, @n-@len_suffix) 
	*/
END





GO
/****** Object:  UserDefinedFunction [util].[trim]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [util].[trim]
(
	@s varchar(200)
	, @return_null bit = 1 
)
RETURNS varchar(200)
AS
BEGIN
	declare @result as varchar(max)= replace(replace(convert(varchar(200), ltrim(rtrim(@s))), '"', ''), '''' , '')
	if @return_null =0 
		return isnull(@result , '') 
	return @result 
END










GO
/****** Object:  Table [def].[Col_hist]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Col_hist](
	[column_id] [int] IDENTITY(1,1) NOT NULL,
	[eff_dt] [datetime] NOT NULL,
	[object_id] [int] NOT NULL,
	[column_name] [varchar](64) NOT NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_id] [int] NULL,
	[ordinal_position] [smallint] NULL,
	[is_nullable] [bit] NULL,
	[data_type] [varchar](100) NULL,
	[max_len] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[column_type_id] [int] NULL,
	[src_column_id] [int] NULL,
	[delete_dt] [datetime] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) NULL,
	[chksum] [int] NOT NULL,
	[batch_id] [int] NULL,
	[part_of_unique_index] [bit] NULL,
 CONSTRAINT [PK__Hst_column] PRIMARY KEY CLUSTERED 
(
	[column_id] ASC,
	[eff_dt] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Column_type]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Column_type](
	[column_type_id] [int] NOT NULL,
	[column_type_name] [varchar](50) NULL,
	[column_type_description] [varchar](255) NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) NULL,
 CONSTRAINT [PK_Column_type] PRIMARY KEY CLUSTERED 
(
	[column_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Obj]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Obj](
	[object_id] [int] IDENTITY(1,1) NOT NULL,
	[object_type_id] [int] NOT NULL,
	[object_name] [varchar](100) NOT NULL,
	[parent_id] [int] NULL,
	[scope] [varchar](50) NULL,
	[template_id] [smallint] NULL,
	[delete_dt] [datetime] NULL,
	[record_dt] [datetime] NULL CONSTRAINT [DF__Object_record_dt]  DEFAULT (getdate()),
	[record_user] [varchar](50) NULL CONSTRAINT [DF__Object_record_user]  DEFAULT (suser_sname()),
	[prefix] [varchar](50) NULL,
	[object_name_no_prefix] [varchar](100) NULL,
 CONSTRAINT [PK__Object] PRIMARY KEY CLUSTERED 
(
	[object_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Object_type]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Object_type](
	[object_type_id] [int] NOT NULL,
	[object_type] [varchar](100) NULL,
 CONSTRAINT [PK_Object_type] PRIMARY KEY CLUSTERED 
(
	[object_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Prefix]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Prefix](
	[prefix_name] [varchar](100) NOT NULL,
	[default_template_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Property]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Property](
	[property_id] [int] NOT NULL,
	[property_name] [varchar](255) NULL,
	[description] [varchar](255) NULL,
	[scope] [varchar](50) NULL,
	[default_value] [varchar](255) NULL,
	[apply_table] [bit] NULL,
	[apply_view] [bit] NULL,
	[apply_schema] [bit] NULL,
	[apply_db] [bit] NULL,
	[apply_srv] [bit] NULL,
	[apply_user] [bit] NULL,
	[record_dt] [datetime] NULL CONSTRAINT [DF_Property_record_dt_1]  DEFAULT (getdate()),
	[record_user] [varchar](255) NULL CONSTRAINT [DF_Property_record_user_1]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_Property_1] PRIMARY KEY CLUSTERED 
(
	[property_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Property_value]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Property_value](
	[property_id] [int] NOT NULL,
	[object_id] [int] NOT NULL,
	[value] [varchar](255) NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](255) NULL,
 CONSTRAINT [PK_Property_Value] PRIMARY KEY CLUSTERED 
(
	[property_id] ASC,
	[object_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [def].[Template]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [def].[Template](
	[template_id] [smallint] NOT NULL,
	[template] [varchar](100) NULL,
	[record_dt] [datetime] NULL CONSTRAINT [DF_Template_record_dt]  DEFAULT (getdate()),
	[record_name] [varchar](255) NULL CONSTRAINT [DF_Template_record_name]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Batch]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Batch](
	[batch_id] [int] IDENTITY(1,1) NOT NULL,
	[batch_name] [varchar](100) NULL,
	[step_instance_id] [int] NULL,
	[start_dt] [datetime] NULL,
	[end_dt] [datetime] NULL,
	[src_name] [varchar](100) NULL,
	[dest_name] [varchar](100) NULL,
	[rec_cnt_src] [int] NULL,
	[rec_cnt_new] [int] NULL,
	[rec_cnt_changed] [int] NULL,
	[rec_cnt_unchanged] [int] NULL,
	[rec_cnt_deleted] [int] NULL,
	[status_id] [int] NULL,
	[last_error_id] [int] NULL,
 CONSTRAINT [PK_transfer_id] PRIMARY KEY CLUSTERED 
(
	[batch_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Error]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Error](
	[error_id] [int] IDENTITY(1,1) NOT NULL,
	[error_code] [int] NULL,
	[error_msg] [varchar](5000) NULL,
	[error_line] [int] NULL,
	[error_procedure] [varchar](255) NULL,
	[error_procedure_id] [varchar](255) NULL,
	[error_execution_id] [varchar](255) NULL,
	[error_event_name] [varchar](255) NULL,
	[error_severity] [int] NULL,
	[error_state] [int] NULL,
	[error_source] [varchar](255) NULL,
	[error_interactive_mode] [varchar](255) NULL,
	[error_machine_name] [varchar](255) NULL,
	[error_user_name] [varchar](255) NULL,
	[batch_id] [int] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) NULL,
 CONSTRAINT [PK_error_id] PRIMARY KEY CLUSTERED 
(
	[error_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Job]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Job](
	[job_id] [int] IDENTITY(10,10) NOT NULL,
	[job_name] [varchar](50) NULL,
	[record_user] [varchar](100) NULL,
	[record_dt] [datetime] NULL,
 CONSTRAINT [PK_Job] PRIMARY KEY CLUSTERED 
(
	[job_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Job_instance]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Job_instance](
	[job_instance_id] [int] IDENTITY(1,1) NOT NULL,
	[job_id] [int] NOT NULL,
	[job_start_dt] [datetime] NOT NULL,
	[job_end_dt] [datetime] NULL,
	[job_exec_user] [varchar](50) NULL,
	[server_name] [varchar](50) NULL,
 CONSTRAINT [PK_Job_instance] PRIMARY KEY CLUSTERED 
(
	[job_instance_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Schedule]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Schedule](
	[schedule_dt] [datetime] NOT NULL,
	[schedule_name] [varchar](255) NULL,
	[job_name] [varchar](255) NOT NULL,
	[start_today] [bit] NULL,
	[job_sql] [varchar](500) NULL,
	[debug] [bit] NULL,
	[exec_dt] [datetime] NULL,
 CONSTRAINT [PK_Schedule] PRIMARY KEY CLUSTERED 
(
	[schedule_dt] DESC,
	[job_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Status]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Status](
	[transfer_status_id] [int] NOT NULL,
	[transfer_status_name] [varchar](50) NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[transfer_status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Step]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Step](
	[step_id] [int] IDENTITY(1000,1000) NOT NULL,
	[job_id] [int] NOT NULL,
	[step_name] [varchar](50) NULL,
	[group_name] [varchar](50) NULL,
	[src_schema_id] [int] NULL,
	[enabled] [bit] NULL,
	[notes] [varchar](255) NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](100) NULL,
 CONSTRAINT [PK_Step] PRIMARY KEY CLUSTERED 
(
	[step_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [process].[Step_instance]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [process].[Step_instance](
	[step_instance_id] [int] IDENTITY(1,1) NOT NULL,
	[step_id] [int] NOT NULL,
	[job_instance_id] [int] NOT NULL,
	[start_dt] [datetime] NULL,
	[end_dt] [datetime] NULL,
	[last_error_id] [int] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](100) NULL,
 CONSTRAINT [PK_Step_Instance] PRIMARY KEY CLUSTERED 
(
	[step_instance_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[Log_level]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[Log_level](
	[log_level_id] [smallint] NOT NULL,
	[log_level] [varchar](50) NULL,
	[log_level_description] [varchar](255) NULL,
 CONSTRAINT [PK_Log_level_1] PRIMARY KEY CLUSTERED 
(
	[log_level_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[Log_type]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[Log_type](
	[log_type_id] [smallint] NOT NULL,
	[log_type] [varchar](50) NULL,
	[min_log_level_id] [int] NULL,
 CONSTRAINT [PK_Log_type_1] PRIMARY KEY CLUSTERED 
(
	[log_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [def].[Col]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [def].[Col] AS
	SELECT     * 
	FROM  [def].[Col_hist] AS h
	WHERE     (eff_dt =
                      ( SELECT     MAX(eff_dt) max_eff_dt
                        FROM       [def].[Col_hist] h2
                        WHERE      h.column_id = h2.column_id
                       )
              )
		AND delete_dt IS NULL 









GO
/****** Object:  View [def].[Obj_ext]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [def].[Obj_ext]
  
AS
WITH q AS (SELECT        o.object_id, ot.object_type, o.object_name, o.scope, o.parent_id, parent_o.object_name AS parent, parent_o.parent_id AS grand_parent_id, grand_parent_o.object_name AS grand_parent, 
                                                   grand_parent_o.parent_id AS great_grand_parent_id, great_grand_parent_o.object_name AS great_grand_parent, o.delete_dt, o.record_dt, o.record_user, isnull(o.template_id, parent_o.template_id) template_id
												   , o.prefix, o.[object_name_no_prefix]
                         FROM            def.Obj AS o INNER JOIN
                                                   def.Object_type AS ot ON o.object_type_id = ot.object_type_id LEFT OUTER JOIN
                                                   def.Obj AS parent_o ON o.parent_id = parent_o.object_id LEFT OUTER JOIN
                                                   def.Obj AS grand_parent_o ON parent_o.parent_id = grand_parent_o.object_id LEFT OUTER JOIN
                                                   def.Obj AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.object_id
												   where o.delete_dt is null 
												   )
, q2 AS
												   
    (SELECT        object_id, object_type , object_name, 
                                CASE WHEN [object_type] = 'server' THEN [object_name] WHEN [object_type] = 'database' THEN parent WHEN [object_type] = 'schema' THEN grand_parent WHEN [object_type] = 'table'
                                 THEN great_grand_parent WHEN [object_type] = 'view' THEN great_grand_parent END AS srv, CASE WHEN [object_type] = 'server' THEN NULL 
                                WHEN [object_type] = 'database' THEN [object_name] WHEN [object_type] = 'schema' THEN parent WHEN [object_type] = 'table' THEN grand_parent WHEN [object_type] = 'view' THEN
                                 grand_parent END AS db, CASE WHEN [object_type] = 'server' THEN NULL WHEN [object_type] = 'database' THEN NULL 
                                WHEN [object_type] = 'schema' THEN [object_name] WHEN [object_type] = 'table' THEN parent WHEN [object_type] = 'view' THEN parent END AS [schema], 
                                CASE WHEN [object_type] = 'server' THEN NULL WHEN [object_type] = 'database' THEN NULL WHEN [object_type] = 'schema' THEN NULL 
                                WHEN [object_type] = 'table' THEN [object_name] WHEN [object_type] = 'view' THEN [object_name] END AS table_or_view, delete_dt, record_dt, record_user, parent_id, grand_parent_id, great_grand_parent_id, scope, q_1.template_id
								, prefix, [object_name_no_prefix]
      FROM            q AS q_1)
SELECT        
object_id, ISNULL('[' + case when srv<>'LOCALHOST'then srv else null end  + '].', '') + ISNULL('[' + db + '].', '') + ISNULL('[' + [schema] + '].', '') + ISNULL('[' + table_or_view + ']', '') AS full_object_name, object_type, object_name, srv, db, [schema], 
table_or_view, scope, template_id, parent_id, grand_parent_id, great_grand_parent_id, delete_dt, record_dt, record_user
, prefix, [object_name_no_prefix]
, p.[default_template_id]
FROM q2 AS q2_1
left join def.Prefix p on q2_1.prefix = p.prefix_name






GO
/****** Object:  View [def].[Col_ext]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [def].[Col_ext]
AS
SELECT    c.column_id, c.column_name, 
o.[schema], 
o.full_object_name,  c.Column_type_id, ct.Column_type_name, c.prefix, c.[entity_name], c.foreign_column_id , foreign_c.column_name foreign_column_name, lookup_foreign_cols.foreign_sur_pkey  , lookup_foreign_cols.foreign_sur_pkey_name
, c.is_nullable, c.ordinal_position, c.data_type, c.max_len, c.numeric_precision, c.numeric_scale, c.src_column_id,  o.[object_id] , o.[object_name]
, c.chksum
, c.part_of_unique_index
FROM def.Col AS c 
INNER JOIN def.Obj_ext AS o ON c.object_id = o.object_id
LEFT JOIN def.Column_type ct ON c.Column_type_id = ct.Column_type_id
LEFT JOIN def.Col AS foreign_c ON foreign_c.column_id = c.foreign_column_id  AND foreign_c.delete_dt IS NULL 
LEFT JOIN ( 
	SELECT c1.column_id, c1.foreign_column_id, c3.column_id foreign_sur_pkey, c3.column_name foreign_sur_pkey_name
	, ROW_NUMBER() OVER (PARTITION BY c1.column_id ORDER BY c3.ordinal_position ASC) seq_nr 
	FROM def.Col c1
	INNER JOIN def.Col c2 ON c1.[foreign_column_id] = c2.column_id 
	INNER JOIN def.Col c3 ON c3.[object_id] = c2.[object_id] AND c3.Column_type_id=200 -- sur_pkey
	WHERE c1.[foreign_column_id] IS NOT NULL 
) lookup_foreign_cols ON lookup_foreign_cols.column_id = c.column_id AND lookup_foreign_cols.seq_nr = 1 
WHERE        (c.delete_dt IS NULL) 

/*
SELECT * 
FROM vw_column
WHERE column_id IN ( 1140) 
*/









GO
/****** Object:  View [def].[Property_ext]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/* select * from vw_prop*/
CREATE VIEW [def].[Property_ext]
AS
SELECT        o.object_id, o.object_type, o.object_name, 
o.srv, o.db, o.[schema], o.table_or_view, p.property_name property, pv.value, p.default_value
FROM            def.Obj_ext AS o 
INNER JOIN def.Property AS p ON o.object_type = 'table' AND p.apply_table = 1 OR o.object_type = 'view' AND p.apply_view = 1 OR o.object_type = 'schema' AND p.apply_schema = 1 OR o.object_type = 'database' AND 
                         p.apply_db = 1 OR o.object_type = 'server' AND p.apply_srv = 1 
						 OR o.object_type = 'user' AND p.apply_user = 1 
LEFT OUTER JOIN
                         def.Property_Value AS pv ON pv.property_id = p.property_id AND pv.object_id = o.object_id








GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N'Unknown', N'Unknown / not relevant', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N'nat_pkey', N'Natural primary key (e.g. user_key)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N'nat_fkey', N'Natural foreign key (e.g. create_user_key)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N'sur_pkey', N'Surrogate primary key (e.g. user_id)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N'sur_fkey', N'Surrogate foreign key (e.g. create_user_id)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N'attribute', N'low or non repetetive value for containing object. E.g. customer lastname, firstname.', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N'meta data', NULL, CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
SET IDENTITY_INSERT [def].[Obj] ON 

GO
INSERT [def].[Obj] ([object_id], [object_type_id], [object_name], [parent_id], [scope], [template_id], [delete_dt], [record_dt], [record_user], [prefix], [object_name_no_prefix]) VALUES (1, 60, N'C2H_PC\BAS', NULL, NULL, NULL, NULL, CAST(N'2017-05-24 19:23:42.750' AS DateTime), N'C2H_PC\BAS', NULL, NULL)
GO
SET IDENTITY_INSERT [def].[Obj] OFF
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (10, N'table')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (20, N'view')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (30, N'schema')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (40, N'database')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (50, N'server')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (60, N'user')
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgd', 12)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgf', 13)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgh', 8)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgl', 10)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N'target_schema_id', N'used for deriving target table', N'persistent', NULL, 0, 0, 1, NULL, NULL, NULL, CAST(N'2015-08-31 13:18:22.073' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N'has_synonym_id', N'apply syn pattern (see biblog.nl)', N'persistent', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N'2015-08-31 13:18:56.070' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N'has_record_dt', N'add this column (insert date time) to all tables', N'persistent', NULL, 0, 0, 0, 0, 1, NULL, CAST(N'2015-08-31 13:19:09.607' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N'has_record_user', N'add this column (insert username ) to all tables', N'persistent', NULL, 0, 0, 1, 0, 1, NULL, CAST(N'2015-08-31 13:19:15.000' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N'use_linked_server', N'assume that servername = linked_server name. Access server via linked server', N'persistent', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-08-31 17:17:37.830' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N'date_datatype_based_on_suffix', N'if a column ends with the suffix _date then it''s a date datatype column (instead of e.g. datetime)', N'persistent', N'1', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-02 13:16:15.733' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N'is_localhost', N'This server is localhost. For performance reasons we don''t want to access localhost via linked server as we would with external sources', N'persistent', N'0', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-24 16:22:45.233' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N'recreate_tables', N'This will drop and create tables (usefull during initial development)', N'persistent', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N'prefix_length', N'This object name uses a prefix of certain length x. Strip this from target name. ', N'persistent', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N'etl_meta_fields', N'etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source', N'persistent', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (110, N'batch_id', N'Unique number identifying a batch that loaded data into a table. ', N'user', N'0', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (120, N'exec_sql', N'set this to 0 to print the generated sql instead of executing it. usefull for debugging', N'user', N'1', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02 15:04:49.867' AS DateTime), N'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (130, N'log_level', N'controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE', N'user', N'INFO', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02 15:06:12.167' AS DateTime), N'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (140, N'nesting', N'used by dbo.log in combination with log_level  to determine wheter or not to print a message', N'user', N'0', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02 15:08:02.967' AS DateTime), N'')
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (1, N'truncate_insert', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (2, N'drop_insert', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (3, N'delta insert based on a first sequential ascending column', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (4, N'transform based on content type (auto-generate L2 view)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (5, N'transform based on content type (don''t generate L2 view)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (6, N'transfer to switching tables (Datamart)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (7, N'delta insert based on eff_dt column', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (8, N'Datavault Hub & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (9, N'Datavault Hub Sat (part of transfer_method 8)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (10, N'Datavault Link & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (11, N'Datavault Link Sat (part of transfer_method 10)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (12, N'Kimball Dimension', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (13, N'Kimball Fact', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (14, N'Kimball Fact Append', NULL, NULL)
GO
INSERT [process].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (0, N'Unknown')
GO
INSERT [process].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (100, N'Success')
GO
INSERT [process].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (200, N'Error')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (10, N'ERROR', N'Only log errors')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (20, N'WARN', N'Log errors and warnings (SSIS mode)')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (30, N'INFO', N'Log headers and footers')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (40, N'DEBUG', N'Log everything only at top nesting level')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (50, N'VERBOSE', N'Log everything all nesting levels')
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (10, N'Header', 30)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (20, N'Footer', 30)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (30, N'SQL', 40)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (40, N'VAR', 40)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (50, N'Error', 10)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (60, N'Warn', 20)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (70, N'Step', 30)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Unique__Column_obj_col_eff]    Script Date: 22-6-2017 10:10:01 ******/
ALTER TABLE [def].[Col_hist] ADD  CONSTRAINT [IX_Unique__Column_obj_col_eff] UNIQUE NONCLUSTERED 
(
	[object_id] ASC,
	[column_name] ASC,
	[eff_dt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX__Object]    Script Date: 22-6-2017 10:10:01 ******/
ALTER TABLE [def].[Obj] ADD  CONSTRAINT [IX__Object] UNIQUE NONCLUSTERED 
(
	[object_name] ASC,
	[parent_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UIX__Object_id_parent_object_id]    Script Date: 22-6-2017 10:10:01 ******/
ALTER TABLE [def].[Obj] ADD  CONSTRAINT [UIX__Object_id_parent_object_id] UNIQUE NONCLUSTERED 
(
	[object_id] ASC,
	[parent_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [def].[Col_hist] ADD  CONSTRAINT [DF__Column_part_of_unique_index]  DEFAULT ((0)) FOR [part_of_unique_index]
GO
ALTER TABLE [process].[Job] ADD  CONSTRAINT [DF_Job_record_user]  DEFAULT (suser_sname()) FOR [record_user]
GO
ALTER TABLE [process].[Job] ADD  CONSTRAINT [DF_Job_record_dt]  DEFAULT (getdate()) FOR [record_dt]
GO
ALTER TABLE [process].[Job_instance] ADD  CONSTRAINT [DF_Job_Instance_job_start_dt]  DEFAULT (getdate()) FOR [job_start_dt]
GO
ALTER TABLE [def].[Obj]  WITH CHECK ADD  CONSTRAINT [FK__Object__Object] FOREIGN KEY([parent_id])
REFERENCES [def].[Obj] ([object_id])
GO
ALTER TABLE [def].[Obj] CHECK CONSTRAINT [FK__Object__Object]
GO
/****** Object:  StoredProcedure [def].[get_object_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================

declare @obj_id  as int 
exec set_log_level 'debug'
exec [def].[get_object_id] '[LOCALHOST].[My_DWH].[NF].[Center]', @obj_id  output, 'NF'
select @obj_id  

print @obj_id  

-- =============================================
*/

CREATE PROCEDURE [def].[get_object_id] 
	@full_object_name varchar(255) 
	, @obj_id int output 
	, @scope varchar(255) = null 
	, @recursive_depth int = 0
-- e.g. when this proc is called on a table in an unknown database. get_object_id is executed on this database. 
-- but the search algorithm first needs to go up from table->schema->database->server and then down. 
	, @batch_id as int = -1

as
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID)
	--exec process.log 'header', '? ? ?', @proc_name , @full_object_name,  @batch_id
	-- END standard BETL header code... 

	SET NOCOUNT ON;
	declare 
		@full_object_name2 as varchar(255) 
		, @schema as varchar(255) 
		, @parent varchar(255) 
		, @db_name varchar(255) 

	set @full_object_name2 = replace(@full_object_name, @@servername, 'LOCALHOST') 
	--exec process.log 'Step', 'looking for ?, scope ? ', @full_object_name2 , @scope
	

	-- retrieve object meta data. If not found->refresh schema... 
	Set @obj_id = def.object_id(@full_object_name2, @scope) 
	if @obj_id is null or @obj_id < 0 
	begin 
		Set @parent = def.parent(@full_object_name2) 
		if @parent is null or @parent =''
		begin
			-- this happens when a new view is just created in current database. 
			-- try to refresh current database
			exec process.log 'Warn', 'object ? not found in scope ? and no parent ', @full_object_name2, @scope 

			SELECT @db_name = d.name
			FROM sys.dm_tran_locks
			inner join sys.databases d with(nolock) on resource_database_id  = d.database_id
			WHERE request_session_id = @@SPID and resource_type = 'DATABASE' and request_owner_type = 'SHARED_TRANSACTION_WORKSPACE'
			and d.name<>db_name() 
			--print @db_name 

			exec def.refresh @db_name, null, 1
			Set @obj_id = def.object_id(@full_object_name2, @scope) 
			if @obj_id is null or @obj_id < 0 
				exec process.log 'Warn', 'object ? not found', @full_object_name2, @scope 
			goto footer
		end
		exec process.log 'Warn', 'object ? not found in scope ? , trying to refresh parent ? ', @full_object_name2, @scope, @parent
		--set @recursive_depth +=1
		
		exec process.inc_nesting
		exec def.refresh @parent, @scope, 0 -- @recursive_depth 
		exec process.dec_nesting

		Set @obj_id = def.object_id(@full_object_name2, @scope) 
	end 
	if @obj_id <0 -- ambiguous object-id 
	begin
		exec process.log 'ERROR', 'Object name ? is ambiguous. ? duplicates.', @full_object_name, @obj_id 
		goto footer
	end
	--if @obj_id is not null and @obj_id >0  
		--exec process.log 'step', 'Found object-id ?(?)->?', @full_object_name, @scope, @obj_id
	--else 
		--exec process.log 'step', 'Object ?(?) NOT FOUND', @full_object_name, @scope, @obj_id
	-- standard BETL footer code... 
    footer:
	
	--exec process.log 'Footer', 'DONE ? ? ?', @proc_name , @full_object_name, @batch_id
	-- END standard BETL footer code... 
END








GO
/****** Object:  StoredProcedure [def].[getp]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
declare @value varchar(255) 
exec betl.def.getp 'log_level', @Value output 
print 'loglevel' + isnull(@Value,'?')
*/

-- declare @value varchar(255); exec getp 'batch_id', @value 
CREATE PROCEDURE [def].[getp] 
	@prop varchar(255)
	, @value varchar(255) output 
	, @full_object_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @batch_id as int = -1 -- use this for logging. 

as 

begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec process.log 'header', '? ? ?', @proc_name , @prop, @full_object_name
	-- END standard BETL header code... 

  -- first determine scope 
  declare @scope as varchar(255) 
		, @object_id int
		, @prop_id as int 

  select @scope = scope , @prop_id = property_id
  from def.Property
  where [property_name]=@prop

  if @prop_id is null 
  begin 
	--exec process.log 'ERROR', 'Property ? not found in def.Property ', @prop
	goto footer
  end

  if @scope is null 
  begin 
	--exec process.log 'ERROR', 'Scope ? is not defined in def.Property', @prop
	goto footer
  end
  -- scope is not null 

  if @scope = 'user' -- then we need an object_id 
  begin
	set @full_object_name =  suser_sname()
  end
  
  --select @object_id = def.object_id(@full_object_name, null) 
	select @object_id = def.object_id(@full_object_name, null ) 

--  exec get_object_id @full_object_name, @object_id output, @scope=DEFAULT, @recursive_depth=DEFAULT, @batch_id=@batch_id
  if @object_id  is null 
  begin 
	if @scope = 'user' -- then create object_id 
	begin
		insert into def.Obj (object_type_id, object_name) 
		values (60, @full_object_name)
			
		select @object_id = def.object_id(@full_object_name, null) 
	end
	else 
		goto footer
	--exec process.log 'ERROR', 'object not found ? , scope ? ', @full_object_name , @scope
  end
  --exec process.log 'var', 'object ? (?) , scope ? ', @full_object_name, @object_id , @scope 

  select @value = isnull(value,default_value) from def.Property_ext
  where property = @prop  and object_id = @object_id 

  footer:
  --exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @prop, @value , @full_object_name
  -- END standard BETL footer code... 
end





GO
/****** Object:  StoredProcedure [def].[info]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:          Bas van den Berg
-- Create date: 02-03-2012
-- ============================================

/* 
exec def.info '[C2H_PC].[AdventureWorks2014]', 'AW'
exec def.info 

*/
--[LOCALHOST].[AdventureWorks2014].[def].[ErrorLog]

CREATE PROCEDURE [def].[info]
    @full_object_name as varchar(255) =''
	, @scope as varchar(255) =null
	, @batch_id as int = -1

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log 'header', '? ? ? ?', @proc_name , @full_object_name,  @scope, @batch_id
	-- END standard BETL header code... 

	declare @object_id as int
			, @object_name as varchar(255) 
			, @search as varchar(255) 

	--exec refresh @full_object_name 
	--Set @object_id = def.object_id(@full_object_name) 
	--if @object_id is null 
	--	exec show_error 'Object ? not found ', @full_object_name
	--else 
	--	exec process.log 'INFO', 'object_id ?', @object_id 
	
	set @search = replace (@full_object_name, @@SERVERNAME , 'LOCALHOST') 
	declare @replacer as ParamTable
	insert into @replacer values ( '[', '![')
	insert into @replacer values ( ']', '!]')
	insert into @replacer values ( '_', '!_')
	
	
	SELECT @search = REPLACE(@search, param_name, convert(varchar(255), param_value) )
	FROM @replacer;

	set @search  ='%%'+ @search +'%%'
	exec process.log 'step', 'Searching ?', @search 
	
	select o.*, p.value target_schema_id
	from def.obj_ext o
	LEFT OUTER JOIN [meta].[_object] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN [meta].[_object] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN [meta].[_object] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	left join def.vw_prop p on o.object_id = p.object_id and p.property = 'target_schema_id' 
	where ( full_object_name like @search  ESCAPE '!'  or @search is null or @search = '') 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)


	select c.*
	from def.vw_Column c
	LEFT OUTER JOIN [meta].[_object] AS o on c.object_id = o.object_id 
	LEFT OUTER JOIN [meta].[_object] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN [meta].[_object] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN [meta].[_object] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where ( full_object_name like @search  ESCAPE '!'  or @search is null or @search = '') 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)


    footer:
	exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name,  @scope, @batch_id
END















GO
/****** Object:  StoredProcedure [def].[my_info]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:          Bas van den Berg
-- Create date: 02-03-2012
-- ============================================

-- this proc prints out all user bound properties / settings 
-- exec [def].[my_info]
CREATE PROCEDURE [def].[my_info]

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log 'header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @output as varchar(max) = '-- Properties for '+ suser_sname() + ': 
'

	select @output += '-- ' +  isnull(property,'?') + ' = ' + isnull(value, '?') + '
' 
	from def.Property_ext
	where object_name = suser_sname() 

	print @output 

    footer:
	exec process.log 'footer', 'DONE ? ', @proc_name 
END














GO
/****** Object:  StoredProcedure [def].[refresh]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:          Bas van den Berg
-- Create date: 02-03-2012
-- Description:     This proc will refresh the meta data of servers, databases, schemas, tables and views
-- ============================================

/* 
exec set_var 'debug',1
exec set_var 'progress', 1
select * from ##betl_vars
drop table ##betl_vars
exec def.refresh 'BETL'
exec def.refresh 'LOCALHOST',0
exec def.refresh 'LOCALHOST.BETL_Meta.def'
exec def.refresh 'LOCALHOST.BETL_Meta.def.Error'
exec def.refresh '[LOCALHOST].[AdventureWorks2014]'
exec def.refresh 'LOCALHOST.My_Staging.NF.Center'

*/


CREATE PROCEDURE [def].[refresh]
    @full_object_name as varchar(255) 
	, @scope as varchar(255) = null
	, @recursive_depth as int = 0 -- 0->only refresh full_object_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- def.refresh 'LOCALHOST', 0 will only create a record in def._Object for the server BETL
						-- def.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- def.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- def.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill his._Column with all columns meta data for each table and view. 
	, @batch_id as int = -1

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log 'header', '? ? , scope ?, depth ?', @proc_name , @full_object_name, @scope, @recursive_depth
	-- END standard BETL header code... 

	declare @obj_id as int
	
	exec get_object_id @full_object_name, @obj_id output, @scope, @recursive_depth, @batch_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec process.log 'step', 'Object ? not found in scope ? .', @full_object_name, @scope 
		goto footer
	end
	else
	begin 
		exec process.log 'step', 'object_id resolved: ?, scope ? ', @obj_id , @scope
		exec refresh_obj_id @obj_id, @recursive_depth, @batch_id
	end
	
	-- standard BETL footer code... 
    footer:
	exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @recursive_depth, @batch_id
	-- END standard BETL footer code... 

END















GO
/****** Object:  StoredProcedure [def].[refresh_obj_id]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:          Bas van den Berg
-- Create date:		02-03-2012
-- Description:     This proc will refresh the meta data of servers, databases, schemas, tables and views
-- ============================================

/* 
exec set_var 'debug',1
exec set_var 'progress', 1
exec set_var 'exec_sql', 0
select * from ##betl_vars
drop table ##betl_vars
select * from def.obj_ext where full_object_name like '%[idv]%'
select * from def.obj_ext where full_object_name like '%stgl%'
 _relatie_parent_child]%'
exec def.refresh_obj_id 361
exec def.refresh_obj_id 192

select * from vw_column where object_id = 192

SELECT TOP 1000 *
-- DELETE c
  FROM [his].[_Column] c 
  INNER JOIN meta._Object o ON c.[object_id] = o.[object_id]
  WHERE OBJECT_NAME LIKE 'hub%'
  OR OBJECT_NAME LIKE 'sat%'
  OR OBJECT_NAME LIKE 'link%'


  

*/

CREATE PROCEDURE [def].[refresh_obj_id]
    @obj_id int
	, @recursive_depth as int = 0 -- 0->only refresh full_object_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- def.refresh 'LOCALHOST', 0 will only create a record in meta._Object for the server BETL
						-- def.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- def.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- def.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill his._Column with all columns meta data for each table and view. 
	, @batch_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log 'Header', '? ? , depth ?', @proc_name , @obj_id, @recursive_depth
	-- END standard BETL header code... 

	-- in this proc. not matter what exec_sql says: always exec sql. 
	declare @exec_sql as int 
	exec getp 'exec_sql', @exec_sql output
	exec setp 'exec_sql', 1

	declare
			@object_name as varchar(255) 
			, @full_object_name2 varchar(255) 
			, @object_type as varchar(100)
			, @recursive_depth2 as int
			, @lookup_object_type_id as int
             ,@srv as varchar(100)
             ,@sql as varchar(8000)
             ,@sql2 as varchar(8000)
             ,@sql3 as varchar(8000)
             ,@cols_sql as varchar(8000)
             ,@cols_sql_select as varchar(8000)
             ,@db as varchar(100)
             ,@schema as varchar(255)
             ,@server_type as int
			, @nl as varchar(2) = char(13)+char(10)
			, @schema_id int
			, @parent_id int 
			, @p as ParamTable
			, @use_linked_server as bit 
	--		, @is_localhost as bit 
			, @from varchar(255) 
			, @current_db varchar(255) 
			, @full_object_name varchar(255)
			, @entity_name as varchar(255) 

	set @current_db = db_name() 
	
	select 
	@full_object_name = full_object_name
	,@object_type = object_type
	, @object_name = [object_name]
	, @srv = srv
	, @db = db
	, @schema = [schema] 
	--, @parent_id = [parent_id] 
	, @use_linked_server = def.get_prop_obj_id('use_linked_server', @obj_id ) 
--	, @is_localhost = def.get_prop_obj_id('is_localhost', @obj_id )  
	, @entity_name = lower(object_name)
	from def.obj_ext 
	where object_id = @obj_id
	
--	exec process.log 'var', 'object ?.?.?.?', @srv, @db, @schema, @object_name

	if @object_type = 'server'
	begin 
	  -- lookup all db's on this server
	  set @lookup_object_type_id = def.const('database') 
	  exec process.log 'step', 'refreshing server ?', @object_name
	  if @use_linked_server = 1 
	     set @from = 'openquery([<srv>], "select name from sys.databases order by name" )  '
	  else 
		set @from = 'sys.databases'

	  set @sql2 = '
select distinct <object_type_id> object_type_id, NAME object_name, <parent_id> parent_id
from <from> 
where name not in ("master","model","msdb","tempdb") '
				   
  	  set @sql = '
insert into meta._Object (object_type_id, object_name, parent_id) 
	<sql2>
	and NAME not in ( 
		select object_name  from meta._object where parent_id= <parent_id>)
	order by 2
						
update meta._Object 				 			 
set delete_dt = 
	case when q.object_name is null and _Object.delete_dt is null then <dt> 
	when q.object_name is not null and _Object.delete_dt is not null then null end
from meta._Object 
left join (<sql2>) q on _Object.object_name = q.object_name
where _Object.parent_id = <parent_id> 
and  ( (q.object_name is null     and _Object.delete_dt is null ) or 
(q.object_name is not null and _Object.delete_dt is not null ) )
'
	end 

	if @object_type = 'database'
	begin 
		-- lookup all schemas in this db
	   set @lookup_object_type_id= def.const('schema') 
	   exec process.log 'step', 'refreshing database ?', @object_name
	   if @use_linked_server = 1 
		 set @from = 'openquery(<srv>, "select SCHEMA_NAME , schema_owner from <db>.information_schema.SCHEMATA order by SCHEMA_NAME" )  '
	  else 
		set @from =  '<db>.information_schema.SCHEMATA	'

		set @sql2 = ' select distinct <object_type_id> object_type_id, [SCHEMA_NAME] collate Latin1_General_CI_AS as [object_NAME], <parent_id> parent_id
									 from <from> '
  		set @sql = '
insert into meta._Object (object_type_id, object_name, parent_id) 
	<sql2>
where schema_owner = "def" and [schema_NAME] collate Latin1_General_CI_AS not in ( 
	select object_name from meta.[_object] where parent_id = <parent_id> )
					
update meta._Object 				 			 
set delete_dt = case 
when q.object_name is null and _Object.delete_dt is null then <dt> 
when q.object_name  is not null and _Object.delete_dt is not null then null end
from meta._Object 
left join (<sql2>) q on _Object.object_name = q.object_name 
where _Object.parent_id = <parent_id> 
and  ( (q.object_name is null     and _Object.delete_dt is null ) or 
	(q.object_name is not null and _Object.delete_dt is not null ) )
'
	end 

	if @object_type = 'schema'
	begin 
		-- lookup all tables and view in this schema 
	   exec process.log 'step', 'refreshing schema ?', @object_name
	   set @sql3 = ' select distinct table_name object_name, table_type, p.prefix_name prefix
					 from <db>.information_schema.tables 
					 left join meta.Prefix p on [def].[prefix_first_underscore](table_name) = p.prefix_name
					 where table_schema = "<schema>"
				  '

	   if @use_linked_server = 1 
		 set @sql2 = 'select object_name from openquery(<srv>, "<sql3>" )  '
  	     else 
		set @sql2 = @sql3

  		set @sql = '
insert into meta._Object (object_type_id, object_name, parent_id, prefix, object_name_no_prefix ) 
select case when table_type = "VIEW" then def.const("view") else def.const("table") end object_type_id
		, object_name, <parent_id> parent_id 
		, prefix
		, case when prefix is not null and len(prefix)>0 then substring(object_name, len(prefix)+2, len(object_name) - len(prefix)-1) else object_name end object_name_no_prefix
		from 
	(<sql2>) q 
where q.object_name collate Latin1_General_CI_AS not in ( 
	select object_name  from meta.[_object] where parent_id = <parent_id> )
order by q.object_name
					
update meta._Object 				 			 
set delete_dt = case 
when q.object_name is null and _Object.delete_dt is null then <dt> 
when q.object_name  is not null and _Object.delete_dt is not null then null end
from meta._Object 
left join (<sql2>) q on _Object.object_name = q.object_name 
where _Object.parent_id = <parent_id> 
and  ( (q.object_name is null     and _Object.delete_dt is null ) or 
	(q.object_name is not null and _Object.delete_dt is not null ) )
					'
	end 

	if @object_type in ( 'table', 'view' ) 
	begin 
		exec process.log 'step', 'refreshing ? ?', @object_type, @object_name
		set @cols_sql_select = '
select 
	<obj_id> object_id 
, ordinal_position
, column_name --COLLATE SQL_Latin1_General_CP1_CI_AS column_name
, case when is_nullable="YES" then 1 when is_nullable="NO" then 0 else NULL end is_nullable
, data_type 
, character_maximum_length max_len
, case when DATA_TYPE in ("int", "bigint", "smallint", "tinyint", "bit") then cast(null as int) else numeric_precision end numeric_precision
, case when DATA_TYPE in ("int", "bigint'', ''smallint", "tinyint'', "bit") then cast(null as int) else numeric_scale end numeric_scale
, case when def.suffix(column_name, 4) = "_key" then 
			case when lower(def.prefix(column_name, 4)) = "<entity_name>" then 100 else 110 end -- nat_key
		when def.suffix(column_name, 4) = "_sid" 
			then case when def.prefix_first_underscore(column_name) = ''hub'' then 200 else 210 end 
		when column_name= ''etl_data_source'' then 100 -- include this column in nat keys always... 
		when left(column_name, 4) = "etl_" then 999
		else 300 -- attribute
	end derived_column_type_id 
'
		if @use_linked_server = 1 
			set @cols_sql = '
<cols_sql_select>
from openquery( [<srv>], 
"select ordinal_position, COLUMN_NAME collate Latin1_General_CI_AS column_name
, IS_NULLABLE, DATA_TYPE collate Latin1_General_CI_AS data_type, CHARACTER_MAXIMUM_LENGTH max_len
, numeric_precision
, numeric_scale
, derived_column_type_id 
from <db>.information_schema.columns where TABLE_SCHEMA = ""<schema>""
and table_name = ""<object>""
order by ordinal_position asc"
		'
		else
			set @cols_sql = '
<cols_sql_select>
from <db>.information_schema.columns where TABLE_SCHEMA = "<schema>"
and table_name = "<object>"
			'

		
		set @sql = '
-----------------------------------------
-- START refresh_obj_id <full_object_name>(<obj_id>)
-----------------------------------------
BEGIN TRANSACTION T_refresh_columns
BEGIN TRY
	if object_id("tempdb..<tmp_table>") is not null drop table <tmp_table>;

	with cols as ( 
		<cols_sql> 
	) 
	, q as ( 
	select 
	case when src.object_id is null then trg.object_id else src.object_id end object_id 
	, case when src.column_name is null then trg.column_name else src.column_name end column_name
	, src.ordinal_position
	, src.is_nullable
	, def.trim(src.data_type, 0) data_type
	, src.max_len
	, src.numeric_precision
	, src.numeric_scale
	, src.derived_column_type_id
	, [column_type_id]
	, src_column_id
	, trg.chksum old_chksum
	, getdate() eff_dt
	, trg.column_id trg_sur_key
	, case when trg.[prefix] is null AND trg.column_type_id = 110 THEN def.guess_prefix(src.column_name) ELSE trg.[prefix] END prefix
	, case when trg.[entity_name] is null AND trg.column_type_id = 110 THEN def.guess_entity_name(src.column_name) ELSE trg.[entity_name] END entity_name
	, case when trg.foreign_column_id is null AND trg.column_type_id = 110 then def.guess_foreign_column_id(src.column_name) ELSE trg.foreign_column_id END foreign_column_id
	, case when src.object_id is not null then 1 else 0 end in_src
	, case when trg.object_id is not null then 1 else 0 end in_trg
	from cols src
	full outer join def.[_Column] trg on src.object_id = trg.object_id AND src.column_name = trg.column_name
	where 
	not ( src.object_id is null and trg.object_id is null ) 
	and ( trg.object_id is null or trg.object_id in ( select object_id from cols) ) 
	and trg.delete_dt is null 
		
	) , q2 as (
		select *, 
		 checksum("sha1", def.trim(src.ordinal_position, 0)
		 +"|"+def.trim(src.is_nullable, 0)
		 +"|"+def.trim(src.data_type, 0)
		 +"|"+def.trim(src.max_len, 0)
		 +"|"+def.trim(src.numeric_precision, 0)
		 +"|"+def.trim(src.numeric_scale, 0) 
		 +"|"+def.trim(src.entity_name, 0) 
		 +"|"+def.trim(src.foreign_column_id, 0) 
		 ) chksum 
		 from q src
	 ) 
		select 
				case 
				when old_chksum is null then "NEW" 
				when in_src=1 and old_chksum <> chksum and object_id is not null then "CHANGED"
				when in_src=1 and old_chksum = chksum then "UNCHANGED"
				when in_src=0 and in_trg=1 then "DELETED"
				end mutation
				, * 
		into #mut
		from q2
		      
		-- new records
		insert into [his].[_Column] ( object_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, batch_id, column_type_id,src_column_id, prefix, entity_name, foreign_column_id) 
		select object_id,column_name, eff_dt, ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, -1 , derived_column_type_id,src_column_id , prefix, entity_name, foreign_column_id from #mut
		where mutation = "NEW"
  
		-- changed records and deleted records
		set identity_insert [his].[_Column] on
  
		insert into [his].[_Column] ( object_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len, numeric_precision,numeric_scale , delete_dt, column_id, chksum, batch_id, column_type_id, src_column_id , prefix, entity_name, foreign_column_id) 
		select object_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale 
		, case when mutation = "DELETED" then getdate()  else null end delete_dt
		, trg_sur_key -- take target key for deleted and changed records
		, chksum
		, -1
		, column_type_id 
		, src_column_id
		,prefix 
		,  [entity_name]
		, foreign_column_id
		from #mut
		where mutation in ("CHANGED", "DELETED")
  
		set identity_insert [his].[_Column] off

		-----------------------------------
		-- END HISTORIZE <tmp_table>
		-----------------------------------
		USE <current_db>
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
		ROLLBACK TRANSACTION T_refresh_columns
        
	INSERT INTO [meta].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[batch_id]) 
	VALUES (
	[def].Int2Char(ERROR_NUMBER())
	, isnull(ERROR_MESSAGE(),"")
	, [def].Int2Char(ERROR_LINE()) 
	,  isnull(error_procedure(),"")
	, [def].Int2Char(ERROR_SEVERITY())
	, [def].Int2Char(<batch_id>)    )
						       
	update process.[Batch] set end_dt = getdate(), status_id = 200
	, last_error_id = SCOPE_IDENTITY() 
	where batch_id = [def].Int2Char(<batch_id>) 
	declare 
		@msg as varchar(255)
		, @sev as int
	
		set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),""))
		set @sev = ERROR_SEVERITY()

		RAISERROR("Error Occured in [refresh_columns]: %s", @sev, 1,@msg) WITH LOG
	USE <current_db>
END CATCH
-----------------------------------------
-- DONE refresh_obj_id <full_object_name>(<obj_id>)
-----------------------------------------
'
	end

	delete from @p
	insert into @p values ('object_type_id'							, @lookup_object_type_id) 
	
	insert into @p values ('parent_id'				, @obj_id) 
	insert into @p values ('object'					, @object_name ) 
	insert into @p values ('entity_name'			, @entity_name ) 
	insert into @p values ('full_object_name'		, @full_object_name ) 
	insert into @p values ('obj_id'					, @obj_id) 
	insert into @p values ('srv'					, @srv ) 
	insert into @p values ('db'						, @db ) 
	insert into @p values ('schema'				    , @schema ) 
	insert into @p values ('tmp_table'				, '#refresh_cols_tmp_'+replace(@object_name, ' ', '_') ) 
	insert into @p values ('batch_id'				, def.trim(@batch_id,0)) 
	insert into @p values ('date'				    , def.addQuotes(convert(varchar(50), getdate(),109) ) ) 
	insert into @p values ('db-name'				, @db ) 
	insert into @p values ('current_db'				, @current_db ) 
	insert into @p values ('from'					, @from ) 
	exec apply_params @cols_sql_select output, @p
	insert into @p values ('cols_sql_select'						, @cols_sql_select) 
	exec apply_params @cols_sql output, @p
	insert into @p values ('cols_sql'				, @cols_sql) 

	-- select * from @p
	exec apply_params @sql2 output, @p
	insert into @p values ('sql2'					, @sql2) 
	exec apply_params @sql output, @p
	exec apply_params @sql output, @p -- twice because some parameters might contain other parameters


	--print @sql 
	exec process.inc_nesting
	exec process.exec_sql @sql 
	exec process.dec_nesting


	if @recursive_depth> 0 
	begin 
		declare c cursor LOCAL for 
			select full_object_name from def.obj_ext
			where parent_id = @obj_id and delete_dt is null 

		open c
		fetch next from c into @full_object_name2
		while @@FETCH_STATUS=0 
		begin
			set @recursive_depth2= @recursive_depth-1
			exec def.refresh @full_object_name=@full_object_name2, @recursive_depth=@recursive_depth2, @batch_id=@batch_id 
			fetch next from c into @full_object_name2
		end 
		close c
		deallocate c
	end 
	-- standard BETL footer code... 
    footer:
	
	-- restore exec_sql setting 
	exec setp 'exec_sql', @exec_sql

	exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @recursive_depth, @batch_id
	-- END standard BETL footer code... 

END






GO
/****** Object:  StoredProcedure [def].[setp]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec setp 'batch_id', 100
CREATE PROCEDURE [def].[setp] 
	@prop varchar(255)
	, @value varchar(255)
	, @full_object_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @batch_id as int = -1 -- use this for logging. 

as 

begin 
	-- standard BETL header code... 
	set nocount on 
	--declare    @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec process.log 'header', '? ? ?', @proc_name , @prop, @full_object_name
	-- END standard BETL header code... 

  -- first determine scope 
  declare @scope as varchar(255) 
		, @object_id int
		, @prop_id as int 

  select @scope = scope , @prop_id = property_id
  from def.Property
  where [property_name]=@prop

  if @prop_id is null 
  begin 
	--exec process.log 'ERROR', 'Property ? not found in def.Property ', @prop
	goto footer
  end

  if @scope is null 
  begin 
	--exec process.log 'ERROR', 'Scope ? is not defined in def.Property', @prop
	goto footer
  end
  -- scope is not null 

  if @scope = 'user' -- then we need an object_id 
  begin
	set @full_object_name = suser_sname()
  end

	exec get_object_id @full_object_name, @object_id output, @scope=DEFAULT, @recursive_depth=DEFAULT, @batch_id=@batch_id
	if @object_id  is null 
	begin 
		if @scope = 'user' -- then create object_id 
		begin
			insert into def.Obj (object_type_id, object_name) 
			values (60, @full_object_name)
			
			exec def.get_object_id @full_object_name, @object_id output, @scope=DEFAULT, @recursive_depth=DEFAULT, @batch_id=@batch_id	
		end

		if @object_id is null 
			goto footer
			--exec process.log 'ERROR', 'object not found ? , scope ? ', @full_object_name , @scope
	end

	--exec process.log 'var', 'object ? (?) , scope ? ', @full_object_name, @object_id , @scope 
		
	-- delete any existing value. 
	delete from def.Property_value 
	where object_id = @object_id and property_id = @prop_id 

	insert into def.Property_value ( property_id, [object_id], value) 
	values (@prop_id , @object_id, @value)

--	select * from vw_prop	where object_id = @object_id and property like @prop

    footer:
	--exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @prop, @value , @full_object_name
	-- END standard BETL footer code... 
end









GO
/****** Object:  StoredProcedure [process].[create_table]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:          Bas van den Berg
-- ============================================
/* 
exec set_var 'debug',1
exec set_var 'progress', 1
select * from ##betl_vars
--drop table ##betl_vars

->don't create primary keys for performance reasons (lock last page clustered index )
unique indexes:
hubs:
on all nat_pkeys 

hub sats:
on all nat_pkeys 
note that etl_load_dts is included

links
on all sur_fkeys 

link sats
on all sur_fkeys 
note that etl_load_dts is included

*/
--drop PROCEDURE [def].[create_table]

CREATE PROCEDURE [process].[create_table]
    @full_object_name AS VARCHAR(255) 
    , @scope AS VARCHAR(255) 
	, @cols AS def.ColumnTable READONLY
	, @batch_id AS INT = -1
	, @create_pkey AS BIT =1 

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID)
	exec process.log 'header', '? ?, scope ? ?', @proc_name , @full_object_name,  @scope, @batch_id 
	-- END standard BETL header code... 

	declare @sql as varchar(8000) 
			, @col_str as varchar(8000) =''
			, @nl as varchar(2) = char(13)+char(10)
			, @db as varchar(255) 
			, @obj_name as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int
			, @this_db as varchar(255) = db_name()
			, @prim_key as varchar(1000) =''
			, @prim_key_sql as varchar(8000)=''
			, @p ParamTable
			, @unique_index as varchar(1000)=''
			, @index_sql as varchar(4000) 
			, @refresh_sql as varchar(4000) 
			, @recreate_tables as BIT
            , @obj_id AS INT 

	select @schema_id=def.schema_id(@full_object_name, @scope)  -- 
	select 
		@db = db 
		, @schema = [schema]
		, @obj_name =  def.object_name(@full_object_name) 
	from def.obj_ext 
	where object_id = @schema_id

	select @col_str+= case when @col_str='' then '' else ',' end + 
	'['+ column_name + '] ['+ data_type + ']'
		+ case when data_type in ( 'varchar', 'nvarchar', 'char', 'nchar') then  isnull('('+ convert(varchar(10), max_len) + ')', '')
			   when numeric_precision is not null then '('+ convert(varchar(10), numeric_precision) +  
														isnull ( ',' + convert(varchar(10), numeric_scale), '') + ')' 
				else ''
		  end
	   + case when [identity] = 1 then ' IDENTITY(1,1) ' else '' end + 
		case when is_nullable=0 or ( column_type_id in (100,200) )   then ' NOT NULL' else ' NULL' end 
--		case when is_nullable=0   then ' NOT NULL' else ' NULL' end 
		+ case when column_value is null then '' else ' DEFAULT ('+ column_value + ')' end	
		+ ' -- '+ def.column_type_name(column_type_id) +@nl
	from @cols 

	select @prim_key+= case when @prim_key='' then '' else ',' end + 
	'['+ column_name + ']' + @nl
	from @cols 
	where column_type_id = 200 -- sur_pkey
	order by ordinal_position asc

	select @unique_index+= case when @unique_index='' then '' else ',' end + 
	'['+ column_name + ']' + @nl
	from @cols 
	where part_of_unique_index = 1 
	order by ordinal_position asc
	
	-- exec process.log 'VAR', '@unique_index ?', @unique_index
	if @prim_key='' 
		set @prim_key = @unique_index 

	if @unique_index is not null and @unique_index <> '' 
		set @index_sql = '
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"IX_<obj_name_striped>_<schema_id>")
ALTER TABLE <schema>.<obj_name> ADD CONSTRAINT
	IX_<obj_name_striped>_<schema_id> UNIQUE NONCLUSTERED 
	(
	<unique_index>
	) 
'

--skip this for performance reasons... 
	if @prim_key is not null and @prim_key<> '' and @create_pkey=1
		set @prim_key_sql = '
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"PK_<obj_name_striped>_<schema_id>")
ALTER TABLE <schema>.<obj_name> ADD CONSTRAINT
	PK_<obj_name_striped>_<schema_id> PRIMARY KEY CLUSTERED 
	(
	<prim_key>
	) 
'

/*
-- create FK to etl_data_source
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"FK_<obj_name_striped>_<schema_id>_etl_data_source")
begin
	ALTER TABLE <schema>.<obj_name> WITH CHECK ADD  CONSTRAINT 
		FK_<obj_name_striped>_<schema_id>_etl_data_source FOREIGN KEY([etl_data_source])
	REFERENCES [def].[etl_data_source] ([etl_data_source])
	ALTER TABLE <schema>.<obj_name> CHECK CONSTRAINT FK_<obj_name_striped>_<schema_id>_etl_data_source
end
*/
	set @sql ='
-------------------------------------------------
-- Start create table DDL <full_object_name>
-------------------------------------------------	
USE <db> 
'

	select @recreate_tables = def.get_prop_obj_id('recreate_tables', @schema_id ) 
	if @recreate_tables =1 
	begin
		exec process.log 'step', '@recreate_tables =1->drop table ?', @full_object_name
		SET @sql += '
-- recreate table =1 

if object_id(''<schema>.<obj_name>'') is not null and @@servername in ( ''SSIS01-OTA\WW_DEV'') -- only drop on DEV 
	drop table <schema>.<obj_name>
;
'


	END


	SET @sql += '
if object_id(''<schema>.<obj_name>'') is null 
begin 
	CREATE Table <schema>.<obj_name> (
		<col_str>
	) ON [PRIMARY]

	<prim_key_sql>
	<index_sql>
	<refresh_sql>
end

	
USE <this_db> 
-------------------------------------------------
-- End create table DDL <full_object_name>
-------------------------------------------------	
'
SET @refresh_sql = '
	exec betl.def.refresh ''<schema>.<obj_name>'' -- make sure that betl meta data is up to date
'
-- not needed because we do a get_object_id after this, which will also issue a refresh
--	


	INSERT INTO @p VALUES ('full_object_name'		, @full_object_name) 
	INSERT INTO @p VALUES ('db'						, @db) 
	INSERT INTO @p VALUES ('schema'					, @schema) 
	INSERT INTO @p VALUES ('col_str'				, @col_str) 
	INSERT INTO @p VALUES ('prim_key_sql'			, ISNULL(@prim_key_sql,'') ) 
	INSERT INTO @p VALUES ('index_sql'				, ISNULL(@index_sql,'') ) 
	INSERT INTO @p VALUES ('this_db'				, @this_db) 
	INSERT INTO @p VALUES ('obj_name'				, @obj_name) 
	INSERT INTO @p VALUES ('obj_name_striped'		, REPLACE(REPLACE(@obj_name, '[', ''), ']', '') )
	INSERT INTO @p VALUES ('schema_id'				, @schema_id) 
	INSERT INTO @p VALUES ('prim_key'				, @prim_key ) 
	INSERT INTO @p VALUES ('unique_index'		    , @unique_index ) 
	INSERT INTO @p VALUES ('refresh_sql'			, @refresh_sql) 

	EXEC apply_params @sql OUTPUT, @p
	EXEC apply_params @sql OUTPUT, @p -- twice because of nesting

	exec process.exec_sql @sql 

	EXEC def.get_object_id @full_object_name, @obj_id OUTPUT -- this will also do a refresh

	exec process.log 'VAR', 'object_id ? = ?', @full_object_name, @obj_id
	
	IF @obj_id IS NOT NULL 
		-- finally set column_type meta data 
	   UPDATE c 
	   SET c.column_type_id = cols.column_type_id
	   FROM @cols cols
	   INNER JOIN def.Col c ON cols.column_name = c.column_name 
	   WHERE cols.column_type_id IS NOT NULL 
		AND c.[object_id] = @obj_id

--	SET @refresh_sql = '		exec betl.def.refresh ''<schema>.<obj_name>''	'

	-- standard BETL footer code... 
    footer:
	exec process.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @batch_id
	-- END standard BETL footer code... 

END



















GO
/****** Object:  StoredProcedure [process].[dec_nesting]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
log_level

10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [process].[dec_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec getp 'nesting', @nesting output

	set @nesting = isnull(@nesting-1, 0) 
	exec setp  'nesting', @nesting
end









GO
/****** Object:  StoredProcedure [process].[exec_sql]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Bas van den Berg
-- License		: GNU General Public License version 3 (GPLv3)
-- Project	    : http://betl.codeplex.com 
-- Description	: 
-- =============================================
CREATE PROCEDURE [process].[exec_sql]
	@sql as varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @exec_sql bit


	--exec def.get_var 'log_level_id', @log_level_id output
	--if @log_level_id is null 
	--	set @log_level_id= 30 -- info 

	--exec def.get_var 'nesting', @nesting output
	--if @nesting is null 
	--	set @nesting=0

	exec def.getp 'exec_sql', @exec_sql output
	if @exec_sql is null 
		set @exec_sql=1

	exec process.log 'sql', @sql -- whether sql is logged is determined in usp log

	--if @log_level_id>40 -- debug and verbose
	--	if not @nesting>1 -- for debug and verbose -> only exec nesting>1 
	--		return
	--	return -- don

		if @exec_sql =1 
			exec(@sql)
/*	  end try
	  begin catch
	    
		PRINT 
				'-- Error ' + CONVERT(VARCHAR(50), ERROR_NUMBER()) +
				', Severity ' + CONVERT(VARCHAR(5), ERROR_SEVERITY()) +
				', State ' + CONVERT(VARCHAR(5), ERROR_STATE()) + 
				', Line ' + CONVERT(VARCHAR(5), ERROR_LINE())+
				', Msg ' + CONVERT(VARCHAR(1000), ERROR_MESSAGE())+ 
				', SQL: '
		print @sql 
	end catch*/


END







GO
/****** Object:  StoredProcedure [process].[inc_nesting]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
log_level

10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [process].[inc_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec getp 'nesting', @nesting output

	set @nesting = isnull(@nesting+1 , 1) 
	exec setp 'nesting', @nesting
end









GO
/****** Object:  StoredProcedure [process].[log]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec set_var 'log_depth', 3
/*
exec process.log 'info', 'test'

exec process.log 'info', 
'
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
'
*/

CREATE PROCEDURE [process].[log](
--	  @log_level smallint
	--@batch_id as int
	 @log_type varchar(50)  -- ERROR, WARN, INFO, DEBUG
	, @msg as varchar(max) 
	, @i1 as sql_variant = null
	, @i2 as sql_variant = null
	, @i3 as sql_variant = null
	, @i4 as sql_variant = null
	, @i5 as sql_variant = null
)

AS
BEGIN
	SET NOCOUNT ON;
	
	declare @batch_id as int
	exec def.getp 'batch_id', @batch_id output -- we don't want to give 

	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @log_level varchar(255) 
			, @exec_sql as bit
			, @short_msg AS VARCHAR(255) 


	exec def.getp 'log_level', @log_level output 
	exec def.getp 'exec_sql' , @exec_sql output
	exec def.getp 'nesting' , @nesting output

	select @log_level_id = log_level_id
	from util.[Log_level]
	where log_level = @log_level

	if @log_level_id  is null 
	begin
		set @short_msg  = 'invalid log_level '+isnull(@log_level, '' )
		RAISERROR( @short_msg    ,15,1) WITH SETERROR
		goto footer
	end


	select @log_type_id = log_type_id, @min_log_level_id = min_log_level_id
	from util.Log_type
	where log_type = @log_type

	if 	@log_type_id = null 
	begin
		set @short_msg  = 'invalid log_type '+isnull(@log_type, '' )
		RAISERROR( @short_msg    ,15,1) WITH SETERROR
		goto footer
	end

	--print 'log_type:'+ @log_type
	--print 'log_type_id:'+ convert(varchar(255), @log_type_id) 
	--print 'log_level_id:'+ convert(varchar(255), @log_level_id) 
	--print 'log_depth:'+ convert(varchar(255), @log_depth) 

	
	if @log_level_id < @min_log_level_id -- e.g. level = ERROR, but type = sql -> 40 
		return -- don't log
	
	if @nesting>1 and @log_level_id < 50 and @log_type_id not in ( 10,20) -- header, footer
		return -- when log_level not verbose then don't log level 2 and deeper (other than header and footer).

	-- first replace ? by %1 
	declare @i as int=0
			, @j as int = 1
			,@n int = len(@msg)
	set @i = charIndex('?', @msg, @i) 
	while @i>0 
	begin
		set @msg =  SUBSTRING(@msg,1,@i-1)+ '%'+CONVERT(varchar(2), @j) +SUBSTRING(@msg,@i+1, @n-@i+1)
		set @j+= 1
		set @n = len(@msg)
		set @i = charIndex('?', @msg,@i) 
	end 
	
	if @i1 is not null and CHARINDEX('%1', @msg)=0 
		set @msg += ' @i1'
	if @i2 is not null and CHARINDEX('%2', @msg)=0 
		set @msg += ', @i2'
	if @i3 is not null and CHARINDEX('%3', @msg)=0 
		set @msg += ', @i3'
	if @i4 is not null and CHARINDEX('%4', @msg)=0 
		set @msg += ', @i4'
	if @i5 is not null and CHARINDEX('%5', @msg)=0 
		set @msg += ', @i5'
		
	set @msg = replace(@msg, '%1', isnull(convert(varchar(max), @i1), '?') )
	set @msg = replace(@msg, '%2', isnull(convert(varchar(max), @i2), '?') )
	set @msg = replace(@msg, '%3', isnull(convert(varchar(max), @i3), '?') )
	set @msg = replace(@msg, '%4', isnull(convert(varchar(max), @i4), '?') )
	set @msg = replace(@msg, '%5', isnull(convert(varchar(max), @i5), '?') )
	
	
	set @msg = replicate('  ', @nesting)+'-- '+upper(@log_type) + ': '+@msg
	
	--if charindex(@nl, @msg,0) >0 -- contains nl 
	--	set	@msg = '/*'+@nl+@msg+@nl+'*/'
	--set @msg = replace(@msg, @nl , @nl + '--') -- when logging sql prefix with --
	
	SET @short_msg = substring(@msg, 0, 255) 
	if @log_type = 'ERROR'
		RAISERROR( @short_msg ,15,1) WITH SETERROR
--	end
--	ELSE
--		RAISERROR(@msg,10,1) WITH NOWAIT
	PRINT @msg
  
    footer:
END










GO
/****** Object:  StoredProcedure [process].[push]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author		: Bas van den Berg
-- Create date	: 2012-03-04
-- Description	: 
--  Push implements the core of BETL. In it's most simple form it will copy a table from A to B. 
--	but it can also normalize tables based on column content type, 
--	do natural foreign key lookups, create and refresh lookup tables 
--	add meta data columns, etc. 

-- example 1: 
-- exec def.push 'AdventureWorks2014.def.Invoice' -- derive trg using default target schema for AdventureWorks.def

-- betl will try to find the src object. If its name is ambiguous, it will trhow an error, otherwise it
-- will transfer the table using the tranfer_method defined 

-- example 2 using scope : 
-- exec def.push 'Invoice' , 'AW' -- derive trg using default target schema for AdventureWorks.def
-- exec run 'info'

-- exec run 'Refresh [LOCALHOST].[My_Staging].[NF]'
-- exec def.push 'Center' , 'NF'

CREATE PROCEDURE [process].[push]
    @full_object_name as varchar(255)
	, @scope as varchar(255) = null 
	, @batch_id as int = -1
	, @template_id as smallint=0

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	exec setp 'batch_id', @batch_id -- we don't want to give 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log '-------', '--------------------------------------------------------------------------------'
	exec process.log 'header', '? ? scope ? batch_id ? template_id ?', @proc_name , @full_object_name, @scope, @batch_id, @template_id

	exec def.my_info

	--drop table  tempdb..##betl_vars
--	select * from tempdb..##betl_vars
	declare @log_level as varchar(255) =''
		, @exec_sql as varchar(255) =''
	exec [def].[getp] 'LOG_LEVEL', @log_level output 
	exec [def].[getp] 'exec_sql', @exec_sql output 
	exec process.log 'info', 'log_level ?, exec_sql ? ', @log_level , @exec_sql

	-- END standard BETL header code... 

	declare 
			-- source
			@obj_id as int
			, @obj_name as varchar(255) 
			, @prefix as varchar(255) 
			, @obj_name_no_prefix as varchar(255) 
			, @default_template_id smallint
			, @obj_type as varchar(255) 
			, @srv as varchar(255)
			, @db as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int 
			, @cols_pos int = 1
			, @cols ColumnTable
			, @cols_str varchar(4000) 
			, @attr_cols_str varchar(4000) 
--			, @nat_prim_keys ColumnTable
			, @nat_prim_keys_str varchar(4000)
			, @nat_prim_key1 varchar(255) 
			, @nat_prim_key_match as varchar(4000) 

			, @nat_fkeys_str varchar(4000)
			, @nat_fkeys_str2 varchar(4000)
			, @sur_pkey1 varchar(255) 
			, @nat_fkey_match as varchar(4000) 
--			, @attribute_match_str varchar(4000) 

			-- target
			, @trg_obj_id as int
			, @trg_full_obj_name as varchar(255) 
			, @trg_obj_name as varchar(255) 
			, @trg_prefix as varchar(255) 
			--, @trg_obj_schema_name as varchar(255) 
			, @trg_srv as varchar(255)
			, @trg_db as varchar(255) 
			, @trg_schema as varchar(255) 
			, @trg_schema_id as int 
			, @trg_location as varchar(1000) 
			, @trg_cols ColumnTable
			, @trg_scope as varchar(255) 
			, @trg_entity_name as varchar(255) 

			-- lookup
			, @lookup_entity_name as varchar(255) 
			, @lookup_index AS INT 
			, @lookup_col_str AS VARCHAR(255) 
			, @lookup_match_str AS VARCHAR(4000) 

			-- hub
			, @hub_name as varchar(255) 
			, @lookup_hub_or_link_name as varchar(255) 
			, @sat_name as varchar(255) 
			, @link_name as varchar(255) 

			, @full_sat_name as varchar(255) 
			, @trg_sur_pkey1 as varchar(255) 

			-- Dynamic SQL 
			, @nl as varchar(2) = char(13)+char(10)
			, @p as ParamTable
			, @sql as varchar(4000) 
			, @sql2 as varchar(4000) 
			, @sql3 as varchar(4000) 
			, @lookup_sql AS varchar(4000) 
			, @from as varchar(4000) 
			, @from2 as varchar(4000) 
			, @trg_cols_str varchar(4000) 
			, @trg_cols_str_met_alias varchar(4000) 

				-- properties
			, @use_linked_server as bit 
			, @date_datatype_based_on_suffix as bit
			, @is_localhost as bit 
			, @has_synonym_id as bit 
			, @has_record_dt as bit
			, @has_record_user as bit 
			, @etl_meta_fields as bit
			, @recreate_tables as bit
			
			-- other
			, @current_db varchar(255) 	
			, @ordinal_position_offset int 
			, @batch_start_dt as datetime

	select @current_db = db_name() 


	if @batch_start_dt is null or @batch_start_dt < '2016-01-01' -- meaning: very old 
		set @batch_start_dt  = getdate() 

    ----------------------------------------------------------------------------
	exec process.log 'STEP', 'retrieve object_id from name'
	----------------------------------------------------------------------------

	exec process.inc_nesting
	exec get_object_id @full_object_name, @obj_id output, @scope=@scope, @recursive_depth=DEFAULT, @batch_id=@batch_id
	exec process.dec_nesting

	if @obj_id is null or @obj_id < 0 
	begin
		exec process.log 'error',  'object ? not found.', @full_object_name
		goto footer
	end
	else 
		exec process.log 'step' , 'object_id resolved: ?', @obj_id 

	-- first-> refresh the meta data of @obj_id

	exec process.inc_nesting
	exec refresh_obj_id @obj_id
	exec process.dec_nesting

	-- get all required src meta data 
	select 
	@obj_type = object_type
	, @obj_name = [object_name]
	, @prefix = [prefix]
	, @obj_name_no_prefix = [object_name_no_prefix]
	, @default_template_id = default_template_id 
	, @srv = srv
	, @db = db
	, @schema = [schema] 
	, @use_linked_server = def.get_prop_obj_id('use_linked_server', @obj_id) 
	, @date_datatype_based_on_suffix = def.get_prop_obj_id('date_datatype_based_on_suffix', @obj_id) 
	, @is_localhost = def.get_prop_obj_id('is_localhost', @obj_id) 
	, @trg_schema_id = def.get_prop_obj_id('target_schema_id', @obj_id) 
	, @full_object_name = full_object_name
	, @template_id = case when @template_id=0 then template_id else @template_id end -- don't overwrite when specified in proc call
	from def.obj_ext 
	where [object_id] = @obj_id 

	IF ISNULL(@template_id,0)  = 0  -- no transfermethod known-> guess it. 
		SET @template_id = @default_template_id
	
	exec process.log 'VAR', '@template_id ? ', @template_id

	IF @prefix = 'stgh' AND @template_id NOT IN (8,9) 
	BEGIN 
		exec process.log 'error',  'object ? is a hub/hubsat staging table and thus needs transfermethod 8 or 9.', @full_object_name
		goto footer
	END

	IF @prefix = 'stgl' AND @template_id NOT IN (10,11) 
	BEGIN 
		exec process.log 'error',  'object ? is a link/hubsat staging table and thus needs transfermethod 10 or 11.', @full_object_name
		goto footer
	END

	IF @prefix = 'stgd' AND @template_id NOT IN (12) 
	BEGIN 
		exec process.log 'error',  'object ? is a dimension staging table and thus needs transfermethod 12.', @full_object_name
		goto footer
	END
	
	IF @prefix = 'stgf' AND @template_id NOT IN (13,14) 
	BEGIN 
		exec process.log 'error',  'object ? is a fact staging table and thus needs transfermethod 13 or 14.', @full_object_name
		goto footer
	END

	if @obj_type not in ('table', 'view') 
	begin 
		exec process.log 'ERROR', 'You can only push tables and views currently, no ?', @obj_type 
		goto footer
	END
    
    if @trg_schema_id is null 
	begin
		exec process.log 'error',  'Unable to determine target: No target schema specified'
		goto footer
	end 

    ----------------------------------------------------------------------------
	exec process.log 'STEP', 'retrieving source columns'
	----------------------------------------------------------------------------

	insert into @cols 
	select * from def.get_cols(@obj_id)
	 -- select * from @cols 

	 -- do some checks...
	 if ( select count(*) from @cols WHERE column_type_id=100 ) = 0  and @template_id=8 -- we need >0 nat_pkey
	 begin
		exec process.log 'error',  'natural primary keys not found for ?. Please set column_type_id 100 in vw_column.', @full_object_name
		goto footer
	END

	 if ( select count(*) from @cols WHERE column_type_id=110 ) = 0  and @template_id=10 -- we need >0 nat_pkey
	 BEGIN 
		exec process.log 'error',  'natural foreign keys not found for ?. Please set column_type_id 110 in vw_column.', @full_object_name
		goto footer
	 END

	 if ( select count(*) from @cols WHERE column_type_id=300 ) = 0  and @template_id=11 -- we need >0 attributes
	 BEGIN 
		exec process.log 'INFO',  'Link satelite contains no attributes and will not be created', @full_object_name
		goto footer
	 END

	 if ( select count(*) from @cols WHERE column_type_id=300 ) = 0  and @template_id in (9,11) -- we need >0 attributes
	 BEGIN 
		exec process.log 'INFO',  'Satelite contains no attributes and will not be created', @full_object_name
		goto footer
	 END

 	 if ( select count(*) from @cols WHERE column_name='etl_data_source' ) = 0  and @template_id in (8,9,10,11) 
	 BEGIN 
		exec process.log 'ERROR',  'etl_data_source is a required column for hubs,links and sats. Please add this to your source table ?', @full_object_name
		goto footer
	 END

	-- e.g. Link_Relatie_Parent_Child.child_relatie_id  ( NatFkey ) 
	-- relatie.relatie_id  ( foreign_column_name, part of foreign nat_pkey ) 
	-- relatie.hub_relatie_sid ( foreign sur pkey ) 

	exec process.log 'STEP', 'determine target table name'
	select
	 @trg_obj_name = @obj_name_no_prefix
	--, @trg_obj_schema_name= [schema] + '.'+ @obj_name
	, @srv = [srv]
	, @trg_db = [db]
	, @trg_schema = [schema]
	, @trg_srv = [srv]
	, @trg_scope = [scope]
	from def.obj_ext 
	where [object_id] = @trg_schema_id  -- must exist (FK) 

	exec process.log 'VAR', '@trg_obj_name ? ', @trg_obj_name

	set @trg_location = isnull('['+ case when @trg_srv='LOCALHOST' then null else @trg_srv end + '].','') + isnull('['+@trg_db+'].','') + isnull('['+@trg_schema+']','') 

	set @trg_prefix = 
	case 
		when @template_id = 8 then 'hub'
		when @template_id in (9,11) then 'sat'
		when @template_id = 10 then 'link'
		when @template_id = 12 then 'dim'
		when @template_id in ( 13, 14 ) then 'feit'
	end  + '_' 
	
	set @lookup_hub_or_link_name = CASE WHEN @template_id IN (8 ,9) THEN 'hub_'+ isnull(@trg_obj_name,'') 
										WHEN @template_id IN (10,11) THEN 'link_'+ isnull(@trg_obj_name,'') 
									END 
	set @trg_sur_pkey1   = @lookup_hub_or_link_name + '_sid'-- @trg_prefix + isnull(@trg_obj_name,'') +
	set @lookup_hub_or_link_name = @trg_location + '.[' + isnull( @lookup_hub_or_link_name ,'') +']'

	set @trg_obj_name    = @trg_prefix + isnull(@trg_obj_name,'') 

	set @trg_full_obj_name = @trg_location + '.[' + isnull(@trg_obj_name,'') +']'

	set @full_sat_name = @trg_prefix  + '.[' + isnull(@sat_name,'') +']'
	
	exec process.log 'STEP', 'push will copy ?(?) to ?(?) using transfer method ?', @full_object_name, @obj_id, @trg_full_obj_name, @trg_obj_id, @template_id

	select
		@has_synonym_id= def.get_prop_obj_id('has_synonym_id', @trg_schema_id ) 
		, @has_record_dt = def.get_prop_obj_id('has_record_dt', @trg_schema_id ) 
		, @has_record_user = def.get_prop_obj_id('has_record_user', @trg_schema_id ) 
		, @etl_meta_fields = def.get_prop_obj_id('etl_meta_fields', @trg_schema_id) 
		, @recreate_tables = def.get_prop_obj_id('recreate_tables', @trg_schema_id ) 

	set @trg_entity_name = @obj_name_no_prefix
    ----------------------------------------------------------------------------
	exec process.log 'STEP', 'determine target columns'
	----------------------------------------------------------------------------

	-- create sur_pkey 
	if @template_id=8 -- hub
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'hub_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey

	if @template_id=10 -- link
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'link_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey

	set @ordinal_position_offset = 1
	if @template_id IN (9,11)  -- sat
	begin
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'sat_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey

		IF @template_id =9 
			insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
			, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id) 
			values ( 2, 'hub_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 210) -- sur_fkey

		IF @template_id =11 
			insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
			, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id) 
			values ( 2, 'link_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 210) -- sur_fkey

		set @ordinal_position_offset = 2
	end

	-- add link sur_fkey
	INSERT into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,column_type_id, is_nullable
	, [entity_name] ,[numeric_precision] ,[numeric_scale] , [part_of_unique_index]) 
	select row_number() over (order by c.ordinal_position) + @ordinal_position_offset
			,  CASE WHEN ISNULL(c.prefix,'') = '' THEN '' ELSE c.prefix+ '_' END 
				+ ISNULL(sur_fkey.column_name, 'invalid_sur_fkey') column_name 
			, null
			, sur_fkey.data_type
			, sur_fkey.[max_len] 
			, 210
			, 1 [is_nullable]
			, c.[entity_name]
			, sur_fkey.[numeric_precision] 
			, sur_fkey.[numeric_scale] 
			, 1
	from @cols c -- identical 
	INNER JOIN def.Col sur_fkey ON sur_fkey.column_id = c.[foreign_sur_pkey] -- get [foreign_sur_pkey] details
	where 
		( @template_id IN ( 10)  and c.column_type_id in ( 110) ) -- links sur_fkey
	order by c.ordinal_position asc

	SELECT @ordinal_position_offset = isnull(MAX(ordinal_position) ,0) 
	FROM @trg_cols 

	insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,column_type_id, is_nullable
	, [entity_name] ,[numeric_precision] ,[numeric_scale] , [part_of_unique_index] ) 
	select row_number() over (order by ordinal_position) + @ordinal_position_offset
			, column_name 
			, column_value
			,case when @date_datatype_based_on_suffix=1 and def.suffix(column_name, 5) = '_date' then 
				'date' else [data_type]  end 
			, [max_len] 
			, case 
					when [def].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id = 12 
						and ordinal_position = 1 -- dim 
					then 200 
					when [def].[prefix_first_underscore]( column_name ) = 'fkey' and @template_id in (13,14)
						and ordinal_position = 1 -- feit
					then 200 
					when [def].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id = 12 
						and ordinal_position > 1 -- dim 
					then 210 
					when [def].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id in ( 13,14)  -- feit
					then 210 
					else column_type_id end  column_type_id 
			,case when column_type_id in (100, 200, 210) then 0 else [is_nullable] end
			,case when column_type_id in (210) then @trg_entity_name else [entity_name]  end 
			,[numeric_precision] 
			,[numeric_scale] 
			, CASE WHEN @template_id in (9, 11) AND column_type_id in (100, 110)  THEN 1 ELSE 0 END [part_of_unique_index] 
	from @cols c -- identical 
	where 
			( @template_id = 8 and column_type_id in ( 100) ) -- hubs
		or ( @template_id IN (9,11)  and column_type_id in ( 100, 300) ) -- sats
		OR ( @template_id IN (10,11)  and column_type_id in ( 100, 110) ) -- link attributes 
		OR ( @template_id IN (12,13,14)  ) -- facts and dims
	order by ordinal_position asc

	SELECT @ordinal_position_offset = MAX(ordinal_position) 
	FROM @cols 

	if @etl_meta_fields =1 
	begin
		if @template_id IN (9,11)   -- hub sats and link sats
        	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] ) 
			VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_load_dts'	, null				, 'datetime'	, NULL	  , 100			, 0 , 1) 
		else
        	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] ) 
			VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_load_dts'	, null				, 'datetime'	, NULL	  , 999				, 0, 0) 
			
		if @template_id IN ( 9,11)  -- hub sats and link sats
		begin 
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_end_dts'	,  '''2999-12-31''' , 'datetime'	, NULL	  , 999				, 0) 

			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_active_flg'	, 1					, 'bit'			, NULL	  , 999				, 0) 

			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_deleted_flg'	, 0				, 'bit'			, NULL	  , 999				, 0) 
		end

		--insert into @trg_cols 
		--values ( (select max(ordinal_position)+1 from @trg_cols),  'etl_data_source', null , 'varchar', 10, 100, 0, null, null, null)  -- always add to nat pkey
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_run_id'		, null				, 'int'			, NULL	  , 999				, 0) 
	end
					
	if @has_synonym_id=1 
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'synonym_id'		, null				, 'int'			, NULL	  , 999				, 1) 
	if @has_record_dt =1 
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_record_dt'	, 'getdate()'		, 'datetime'	, NULL	  , 999				, 0) 
	if @has_record_user =1 
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]			, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_record_user'	, 'suser_sname()'		, 'varchar'		, 255	  , 999				, 0) 

	declare @create_pkey as bit 
	set @create_pkey = case when @template_id >= 12 then 1 else 0 end 
	exec create_table @trg_full_obj_name, @trg_scope, @trg_cols, @batch_id, @create_pkey

	exec process.inc_nesting 
	exec refresh_obj_id @trg_schema_id -- refresh schema again. add trg to meta data. 
	exec get_object_id @trg_full_obj_name , @trg_obj_id output, @trg_scope, @batch_id
	exec process.dec_nesting

	if @trg_obj_id is null 
	begin
		exec process.log 'error',  'object ?(?) cannot be created', @trg_full_obj_name, @trg_scope
		goto footer
	end

	exec process.log 'STEP', 'building column strings'
	-- construct string from cols 
	 set @cols_str = ''
	 select @cols_str+=case when @cols_str='' then '' else ',' end + 'src.'+column_name
	 from @cols
	 where column_type_id <> 999 -- no meta cols
	 order by ordinal_position asc

	 SET @attr_cols_str=''
	 select @attr_cols_str+= 'src.'+column_name + ','
	 from @cols
	 where column_type_id = 300
	 order by ordinal_position asc

	 
	 --set @attribute_match_str=''
	 --select @attribute_match_str+=case when @attribute_match_str='' then 'src.' else ' AND src.' end 
	 --+  cols.column_name + ' = trg.' + cols.column_name 
	 --from @cols cols
	 --where column_type_id = 300 -- attribute
	
	set @nat_prim_keys_str=''
	select @nat_prim_keys_str+=case when @nat_prim_keys_str='' then '' else ',' end + 'src.'+column_name
	from @cols WHERE column_type_id=100

	set @nat_fkeys_str=''
	select @nat_fkeys_str+=case when @nat_fkeys_str='' then '' else ',' end + 'src.'+column_name
	from @cols WHERE column_type_id=110

	set @nat_fkeys_str2=''
	select @nat_fkeys_str2+=case when @nat_fkeys_str2='' then '' else ',' end + column_name
	from @cols WHERE column_type_id=110

	select @nat_prim_key1 = column_name
	from @cols 
	WHERE column_type_id=100
	AND ordinal_position = ( select min(ordinal_position ) from @cols WHERE column_type_id=100 ) 

	--build @nat_prim_key_match 
	set @nat_prim_key_match =''
	select @nat_prim_key_match += case when @nat_prim_key_match ='' then 'src.' else ' AND src.' end 
	+  cols.column_name + ' = trg.' + cols.column_name 
	from @cols cols
	where ( column_type_id = 100 AND @template_id in (8, 9)   )  OR 
		  ( column_type_id = 110 AND @template_id in (10, 11) )  
	 -- natprim_keys 

	select @sur_pkey1 = column_name
	from @trg_cols
	where column_type_id = 200 AND ordinal_position = ( select min(ordinal_position ) from @trg_cols WHERE column_type_id=200 ) 

	set @nat_fkey_match =''
	select @nat_fkey_match += case when @nat_fkey_match ='' then 'src.' else ' AND src.' end 
	+  cols.column_name + ' = trg.' + cols.column_name 
	from @cols cols
	where column_type_id = 110 -- natfkeys 

	set @trg_cols_str=''
	set @trg_cols_str_met_alias=''
	select @trg_cols_str+=case when @trg_cols_str='' then '' else ',' end + column_name
		, @trg_cols_str_met_alias+=case when @trg_cols_str_met_alias='' then '' else ',' end + 'trg.'+ column_name
	from @trg_cols
		where 
		( 
		  ( column_type_id in (  210, 300) and @template_id=10 ) or 
		  ( column_type_id in ( 100, 110, 300) and @template_id IN ( 9,11)  ) or 
		  ( column_type_id in ( 100) and @template_id=8 )  or
		  ( @template_id in (1, 12,13,14)  ) 
		) AND column_name <> 'etl_load_dts' -- etl_load_dts is added manually
	order by ordinal_position asc

	exec process.log 'var', 'cols_str ?', @cols_str
	exec process.log 'var', 'trg_cols_str ?', @trg_cols_str

	exec process.log 'var',  '@nat_prim_keys_str ?'    , @nat_prim_keys_str
	exec process.log 'var',  '@nat_prim_key_match ?'   , @nat_prim_key_match
	exec process.log 'var',  '@nat_prim_key1 ?'        , @nat_prim_key1 

	exec process.log 'var',  '@nat_fkeys_str ?'  ,  @nat_fkeys_str
	exec process.log 'var',  '@nat_fkeys_str2 ?'  ,  @nat_fkeys_str2
	exec process.log 'var',  '@nat_fkey_match ?' ,  @nat_fkey_match
	exec process.log 'var',  '@sur_pkey1 ?'      ,  @sur_pkey1

	/*
	else -- trg object exists
	begin
		exec process.inc_nesting
		exec refresh_obj_id @trg_obj_id -- refresh trg columns 
		exec process.dec_nesting

		insert into @trg_cols 
		select * from def.get_cols(@trg_obj_id)
--		where column_type_id <> 999 -- skip meta data cols 
--			and ( @template_id <> 8 or column_type_id in ( 100) ) 
--			and ( @template_id <> 9 or column_type_id in ( 100, 300) ) 
	end
	-- POST: trg exists. @trg_obj_id is not null 
	*/
	-- now we need to build the transfer sql statement from src to trg

	--if @debug =1 
	--begin 
	--	select * from @trg_cols
	--	select * from @cols
	--end

	exec process.log 'STEP', 'build push sql'
	
	set @sql=''
	set @sql2 = '
---------------------------------------------------------------------------------------------------
-- start transfer method <template_id> <full_object_name>(<obj_id>) to <trg_full_obj_name>(<trg_obj_id>)
---------------------------------------------------------------------------------------------------
select ''<trg_full_obj_name>'' trg_full_obj_name
'	

	  exec process.log 'step', 'transfering ?(?) to ?(?) ', @full_object_name, @obj_id, @trg_full_obj_name, @trg_obj_id
	  if @use_linked_server = 1 
	     set @from = 'openquery(<srv>, "select count(*) cnt from <full_object_name> ") '
	  else 
		set @from = 'select count(*) cnt from <full_object_name>'

		/*
	  set @sql2 += '
update def.[Batch] 
	set rec_cnt_src = cnt from ( 
		select cnt from (<from>)  q
	) q where [batch_id] = <batch_id> 
'*/

	delete from @p
	insert into @p values ('full_object_name'		, @full_object_name) 
	insert into @p values ('trg_full_obj_name'		, @trg_full_obj_name) 
	insert into @p values ('srv'					, @srv ) 
	insert into @p values ('batch_id'				, @batch_id ) 
	insert into @p values ('obj_id'					, @obj_id) 
	insert into @p values ('trg_obj_id'				, @trg_obj_id) 
	insert into @p values ('template_id'		, @template_id) 
	
	exec apply_params @from output, @p
	insert into @p values ('from'					, @from) 
	exec apply_params @sql2 output, @p
	set @sql+= @sql2

	set @from2 = 'select <top> <cols> from <full_object_name>'
	if @use_linked_server = 1 
	    set @from = 'openquery(<srv>, "<from2> ") '
	if @template_id is null 
	begin 
		set @template_id=1 
		--exec show_error 'please specify a template_id by editing def.obj_ext'
		-- goto footer
	end

	if @template_id in (1,12,13)   -- truncate insert
	begin 
		set @sql2 = '
-- truncate insert
use <trg_db>;
update betl.def.batch
set ROW_COUNT = ( select count(*) from <full_object_name> src ) 
where RUNCOMP_ID = <batch_id> 

use <trg_db>;
truncate table <trg_full_obj_name>;
insert into <trg_full_obj_name>(<trg_cols_str>)
	select <cols_str> from <full_object_name> src;
use <current_db>
' 
	end -- truncate insert

	if @template_id in (14)   -- append insert
	begin 
		set @sql2 = '
-- truncate insert
use <trg_db>;
update betl.def.batch
set ROW_COUNT = ( select count(*) from <full_object_name> src ) 
where RUNCOMP_ID = <batch_id> 

use <trg_db>;
insert into <trg_full_obj_name>(<trg_cols_str>)
	select <cols_str> from <full_object_name> src;
use <current_db>
' 
	end -- truncate insert

	
	if @template_id=8 -- Datavault Hub  (CDC and delete detection)
	begin
		--build HUB 
		set @sql2 = '
-- build HUB 
use <trg_db>;
update betl.def.batch
set ROW_COUNT = ( select count(*) from <full_object_name> src ) 
where RUNCOMP_ID = <batch_id> 

-- insert new hub keys
insert into <trg_full_obj_name>(<trg_cols_str>, etl_run_id, etl_load_dts)
	select distinct <nat_prim_keys_str> , <batch_id>, ''<batch_start_dt>''
	from <full_object_name> src
	left join <trg_full_obj_name> trg on <nat_prim_key_match>
	where trg.<nat_prim_key1> is null -- not exist
	
	declare @n1 as int =@@rowcount
  		  , @msg1 as varchar(255) 
	set @msg1 = ''cnt_hubs :''+ convert(varchar(255), @n1) 
	exec betl.def.log <batch_id>, @msg1
	update betl.def.batch
	set cnt_hubs = @n1
	where RUNCOMP_ID = <batch_id> 
'
	end

	if @template_id IN ( 9,11)  -- Datavault Sat (CDC and delete detection)
	begin
		-- build SAT
		set @sql2 = '
-- build SAT
use <trg_db>;
declare @src_cnt as int
select @src_cnt = count(*) from <full_object_name> src 

update betl.def.batch
set ROW_COUNT = @src_cnt
where RUNCOMP_ID = <batch_id> 

use <trg_db>;
insert into <trg_full_obj_name>(<trg_sur_pkey1>, <trg_cols_str>, etl_run_id, etl_load_dts)
	select trg.<trg_sur_pkey1>, src.*, <batch_id>, ''<batch_start_dt>''
	from ( 
		select <trg_cols_str>
		from <full_object_name> src
		except 
		select <trg_cols_str>
		from <trg_full_obj_name> trg
		where trg.etl_active_flg=1 and trg.etl_deleted_flg=0
	) src
	left join <lookup_hub_or_link_name> trg on <nat_prim_key_match>

	declare @n2 as int =@@rowcount
		, @msg2 as varchar(255) 
	set @msg2 = ''cnt_sats :''+ convert(varchar(255), @n2) 
	exec betl.def.log <batch_id>, @msg2
	update betl.def.batch
	set cnt_sats = @n2
	where RUNCOMP_ID = <batch_id> 
'

set @sql3= '
use <trg_db>;
declare @src_cnt as int
select @src_cnt = count(*) from <full_object_name> src 
if @src_cnt=0 
	goto footer

-- delete detection
insert into <trg_full_obj_name>(<trg_sur_pkey1>, <trg_cols_str>, etl_run_id, etl_load_dts, etl_deleted_flg)
	select trg.<trg_sur_pkey1>, <trg_cols_str_met_alias>, <batch_id>, ''<batch_start_dt>'', 1 etl_deleted_flg
	from <trg_full_obj_name> trg
	left join <full_object_name> src on <nat_prim_key_match>
	where src.<nat_prim_key1> is null -- key does not exist anymore in src
	and trg.etl_active_flg = 1 and trg.etl_deleted_flg = 0 

	declare @n3 as int =@@rowcount
		  , @msg3 as varchar(255) 
	set @msg3 = ''cnt_deletes :''+ convert(varchar(255), @n3) 

	exec betl.def.log <batch_id>, @msg3
	update betl.def.batch
	set cnt_deletes = @n3
	where RUNCOMP_ID = <batch_id> 

-- end date old sat records
update trg set etl_active_flg = 0 , etl_end_dts = src.etl_load_dts
from <trg_full_obj_name> trg
inner join <trg_full_obj_name> src on <nat_prim_key_match> and src.etl_run_id = <batch_id>
where trg.etl_active_flg = 1 and trg.etl_load_dts < src.etl_load_dts

footer:
' 
	end

	if @template_id=10 -- Datavault Link 
	BEGIN
		SET @lookup_sql =''
		SET @lookup_col_str =''
		SET @lookup_match_str = ''

		SELECT @lookup_sql += '
INNER JOIN '+ foreign_cols.[full_object_name] + ' as lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) 
			+ ' ON lookup_'+ CONVERT(VARCHAR(25), cols.ordinal_position) +'.' + cols.[foreign_column_name] + ' = src.' + cols.column_name 
			, @lookup_col_str += CASE WHEN @lookup_col_str ='' THEN '' ELSE ',' END 
			+'lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.'+ [foreign_cols].column_name + ' as '  
			+ CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [foreign_cols].column_name + '
			'
			, @lookup_match_str += CASE WHEN @lookup_match_str ='' THEN '' ELSE ' AND ' END 
			+'lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.'+ [foreign_cols].column_name + 
			' = trg.' + CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [foreign_cols].column_name 

		FROM @cols cols
		INNER JOIN def.vw_column [foreign_cols] ON cols.[foreign_sur_pkey] = foreign_cols.column_id
		WHERE cols.column_type_id = 110 -- nat_fkey 

		--exec process.log 'var', 'lookup_sql ?', @lookup_sql
		--exec process.log 'var', 'lookup_col_str ?', @lookup_col_str 
		
		--build HUB 
		set @sql2 = '
-- build LINK
use <trg_db>;
update betl.def.batch
set ROW_COUNT = ( select count(*) from <full_object_name> src ) 
where RUNCOMP_ID = <batch_id> 

-- 2017-02-15 we decided to trunc links because we do not do delete detection in links
truncate table <trg_full_obj_name>
-- insert new link keys
insert into <trg_full_obj_name>(<trg_cols_str>, <nat_fkeys_str2>, etl_data_source, etl_run_id, etl_load_dts)
select <lookup_col_str>, <nat_fkeys_str>, 
src.etl_data_source
, <batch_id> etl_run_id
, ''<batch_start_dt>'' etl_load_dts
from <full_object_name> src
<lookup_sql>
left join <trg_full_obj_name> trg on <lookup_match_str>
where trg.<sur_pkey1> is null -- not exist
	
	declare @n4 as int =@@rowcount
  		  , @msg4 as varchar(255) 
	set @msg4 = ''cnt_hubs :''+ convert(varchar(255), @n4) 
	exec betl.def.log <batch_id>, @msg4
	update betl.def.batch
	set cnt_hubs = @n4
	where RUNCOMP_ID = <batch_id> 
'
	end
	
	insert into @p values ('full_sat_name'			, @full_sat_name) 
	insert into @p values ('lookup_hub_or_link_name'			, @lookup_hub_or_link_name)  
	insert into @p values ('trg_sur_pkey1'			, @trg_sur_pkey1) 
	insert into @p values ('cols_str'			, @cols_str) 
	insert into @p values ('attr_cols_str'			, @attr_cols_str) 
	
	INSERT into @p values ('trg_cols_str'		, @trg_cols_str) 
	insert into @p values ('trg_cols_str_met_alias'		, @trg_cols_str_met_alias) 

	insert into @p values ('trg_db'				, @trg_db) 
	insert into @p values ('batch_start_dt'		, @batch_start_dt) 
	insert into @p values ('current_db'			, @current_db) 
	insert into @p values ('lookup_col_str'		, @lookup_col_str ) 
	insert into @p values ('sur_pkey1'			, @sur_pkey1) 
	insert into @p values ('lookup_match_str'	, @lookup_match_str ) 

	insert into @p values ('nat_prim_keys_str'	, @nat_prim_keys_str ) 
	insert into @p values ('nat_prim_key1'		, @nat_prim_key1 ) 
	insert into @p values ('nat_prim_key_match'	, @nat_prim_key_match ) 

	insert into @p values ('nat_fkeys_str'		, @nat_fkeys_str ) 
	insert into @p values ('nat_fkeys_str2'		, @nat_fkeys_str2 ) 

	
	INSERT into @p values ('top'				, '')  -- you can fill in e.g. top 100 here

	exec apply_params @lookup_sql output, @p
	insert into @p values ('lookup_sql'			, @lookup_sql) 

	exec apply_params @sql2 output, @p
	exec apply_params @sql3 output, @p

	set @sql+= @sql2

	exec process.exec_sql @sql 
	exec exec_sql @sql3

	-- END standard BETL footer code... 
	if @template_id IN ( 8)  -- Datavault Hub Sat (CDC and delete detection)
		exec [def].[push]
			@full_object_name 
			, @scope 
			, @batch_id 
			, @template_id = 9 -- only sat

	if @template_id IN ( 10)  -- Datavault Link Sat (CDC and delete detection)
		exec [def].[push]
			@full_object_name 
			, @scope 
			, @batch_id 
			, @template_id = 11 -- only sat
	-- standard BETL footer code... 

    footer:
	exec process.log 'footer', 'DONE ? ? scope ? batch_id ?', @proc_name , @full_object_name, @scope, @batch_id
END 





GO
/****** Object:  StoredProcedure [process].[run]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 30-07-2015
-- Description:	this proc starts the betl engine.
-- syntax:
-- run '<CMD> <src> |<trg>|'

-- <CMD> = PUSH | TRUNC
-- <src> = string in format [<server>.][<db>.][<schema>.]<object>;
-- <trg> = string in format [<server>.][<db>.][<schema>.]<object>;

-- example 1: exec def.run 'PUSH AdventureWorks2014.def.Invoice' -- derive trg using default target schema for AdventureWorks.def
-- example 2: exec def.run 'PUSH localhost.AdventureWorks2014.def.Invoice'

-- betl will try to find the src object. If its name is ambiguous, it will trhow an error, otherwise it
-- will transfer the table using the tranfer_method defined 

-- SCOPE: 
-- in SSIS we enter the command string in the name of the Control flow item. So we like to keep it short and simple (no full object names). 
-- For this reason we added the scope parameter, which can be added automatically via SSIS using a package variable.  
-- The scope refers to one or more objects ( via the scope property). I usually link a scope only to a single schema object. 

-- example 3: exec def.run 'PUSH Invoice', 'AW'
-- The schema localhost.AdventureWorks2014.def has a scope property named 'AW'

-- example 4: exec def.run 'Refresh Invoice', 'AW'


-- =============================================

CREATE  PROCEDURE [process].[run]
	-- Add the parameters for the stored procedure here
	@cmd_str as varchar(2000)
	,@scope as varchar(255) = null 
	,@batch_id int=-1  -- this id is used for logging and lineage. It refers to the batch that called this usp. e.g. a SSIS package. 
AS
BEGIN
	set nocount on
	exec def.setp 'nesting', 0 -- reset nesting
	exec def.setp 'batch_id', @batch_id 

	declare @log_level_id  as smallint
		, @log_level as varchar(255)
		, @exec_sql as bit

	exec def.getp 'log_level', @log_level OUTPUT
	if @log_level is null  -- no log level set yet-> make it INFO
		exec def.setp 'log_level', 'INFO'

	exec def.getp 'exec_sql', @exec_sql OUTPUT
	if @exec_sql  is null  
	begin
		set @exec_sql  = 1 -- default
		exec def.setp 'exec_sql',@exec_sql  
	end

	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec process.log 'header', '? "?", "?", ?', @proc_name , @cmd_str , @scope, @batch_id
	-- END standard BETL header code... 
	
	exec getp 'log_level',  @log_level output
	exec process.log 'INFO', 'log_level=?, exec_sql=?', @log_level, @exec_sql

	declare 
		@cmd as varchar(255)
		,@src as varchar(255)
		,@param1 as varchar(255)

	--declare @lst SplitList
	--insert into @lst select * from def.Split(@cmd_str, ' ')
	--select @src = def.trim(item, 1) from @lst where i=2

	declare @i as int 
	set @i = CHARINDEX(' ',@cmd_str,0)
	if not @i>0 
	   set @i = len(@cmd_str)+1  -- e.g. for run 'info'

	select @cmd = def.trim(  SUBSTRING(@cmd_str,1,@i-1) ,1 )
	select @src = def.trim(  SUBSTRING(@cmd_str,@i, len(@cmd_str) - @i+1)  ,1 )
	--select @param1 = def.trim(item, 1) from @lst where i=3

	exec process.log 'step' , 'cmd: ?, src: ?, param1: ?',  @cmd, @src, @param1

	if @cmd not in ( 'PUSH', 'HIS', 'TRUNC', 'REFRESH', 'INFO', 'REFRESH_VIEWS') 
	begin 
		exec process.log 'ERROR' , 'Invalid Command ?',@cmd
		goto footer
	end

	if @cmd in( 'REFRESH') 
	begin 
		exec process.inc_nesting
		exec refresh @src, @scope, @param1, @batch_id
		exec process.dec_nesting

		exec info @src, @scope,  @batch_id
	end 

	if @cmd in( 'INFO') 
	begin 
		exec info @src,  @scope, @batch_id
	end 
	
	if @cmd in( 'PUSH', 'STG', 'L0') 
	begin 
		exec process.inc_nesting
		--print 'src='+ @src 
		exec push @src, @scope, @batch_id
		exec process.dec_nesting

		exec process.log 'step' , '@cmd ?',  @cmd
	end 
	
	if @cmd in( 'REFRESH_VIEWS') 
	begin 
		exec process.log 'step' , '@cmd ? ?',  @cmd, @param1
		exec refresh_views @param1
	end 

	-- standard BETL footer code... 
	footer:
	exec process.log 'footer', 'DONE ? "?", "?", ?', @proc_name , @cmd_str , @scope, @batch_id
	-- END standard BETL footer code... 
END









GO
/****** Object:  StoredProcedure [util].[apply_params]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*
Declare @p as ParamTable
,	@sql as varchar(8000) = 'select <aap> from <wiz> where <where>="nice" '
insert into @p values ('aap', 9)
insert into @p values ('wiz', 'woz')

print @sql 
exec apply_params @sql output , @p
print @sql 


*/
CREATE PROCEDURE [util].[apply_params]
	@sql as varchar(max) output
	, @params as ParamTable readonly
	as
BEGIN
	declare 
		@nl as varchar(2) = CHAR(13) + CHAR(10)
	declare
		@tmp as varchar(max) ='-- [apply_params]'+@nl

	SET NOCOUNT ON;


	--if @progress =1 
	--begin
	--	select @tmp += '-- '+ param_name + ' : '+ replace(isnull(convert(varchar(max), p.param_value), '?'), @nl, @nl+'--')   + @nl  
	--	from @params p

	--	print @tmp 
	--end
		
	-- insert some default params. 
	select @sql = REPLACE(@sql, '<'+ p.param_name+ '>', isnull(convert(varchar(max), p.param_value), '<' + isnull(p.param_name, '?') + ' IS NULL>'))
	from @params  p

	declare @default_params ParamTable
	insert into @default_params  values ('"', '''' ) 
	insert into @default_params  values ('<dt>', ''''+ convert(varchar(50), GETDATE(), 121)  + '''' ) 

	select @sql = REPLACE(@sql, p.param_name, convert(Varchar(255), p.param_value) )
	from @default_params  p
END












GO
/****** Object:  StoredProcedure [util].[refresh_views]    Script Date: 22-6-2017 10:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec refresh_views 'MyDB'
--SELECT * FROM  ##betl_vars
CREATE PROCEDURE [util].[refresh_views]
	@db_name as varchar(255)  
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql AS VARCHAR(MAX) 
		, @cur_db as varchar(255) 
    set @cur_db = DB_NAME()

	SET @sql = '
DECLARE @sql AS VARCHAR(MAX) =''use '+@db_name + ';
''
use '+@db_name+ ';
SELECT @sql += ''EXEC sp_refreshview '''''' + schema_name(schema_id)+ ''.''+ name + '''''' ;
''
  FROM sys.views
set @sql+= ''USE '+@Cur_db+ '''
PRINT @sql 
exec(@sql)
use ' +@cur_db+ '
'
--	PRINT @sql 
   EXEC(@sql)

   




/* 
   declare @cur_db as varchar(255) 
			,@sql as varchar(255) 
   select @cur_db = DB_NAME()
   set @sql = 'use '+@db_name
   exec (@sql) 

   select DB_NAME()
	DECLARE @view_name AS NVARCHAR(500);
	DECLARE views_cursor CURSOR FOR 
		SELECT TABLE_SCHEMA + '.' +TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
		WHERE	TABLE_TYPE = 'VIEW' 
		ORDER BY TABLE_SCHEMA,TABLE_NAME 
	
	OPEN views_cursor 

	FETCH NEXT FROM views_cursor 
	INTO @view_name 

	WHILE (@@FETCH_STATUS <> -1) 
	BEGIN
		BEGIN TRY
			EXEC sp_refreshview @view_name;
			PRINT @view_name;
		END TRY
		BEGIN CATCH
			PRINT 'Error during refreshing view "' + @view_name + '".'+ + convert(varchar(255), isnull(ERROR_MESSAGE(),''))	;
		END CATCH;

		FETCH NEXT FROM views_cursor 
		INTO @view_name 
	END 

	CLOSE views_cursor; 
	DEALLOCATE views_cursor;

   set @sql = 'use '+@cur_db
   exec (@sql) 
*/
END















GO
USE [master]
GO
ALTER DATABASE [BETL] SET  READ_WRITE 
GO
