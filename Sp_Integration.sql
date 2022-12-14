USE [Daftar_Taj]
GO
/****** Object:  StoredProcedure [dbo].[Sp_IntegrateDaftar]    Script Date: 22/05/1401 07:59:28 ق.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[Sp_IntegrateDaftar]
 @ServerIp nvarchar(20),
 @DateFrom nvarchar(15),
 @DateUntil nvarchar(15),
 @Connect bit,
 @Execute bit,
 @message nvarchar(550) output
as  
	if(@Connect=1)
	begin
		declare @ServerSqlLogin nvarchar(20);
		declare @ServerSqlPass nvarchar(20);

		select @ServerSqlLogin=s.xServerSQLLoginName, @ServerSqlPass=s.xServerSQLLoginPass from Taj_Tb_Servers s
		where s.xServerIP=@ServerIp

		begin try
			EXEC master.dbo.sp_addlinkedserver
				@server     = @ServerIp
				--@srvproduct = N'Daftar_taj'
				--@provider   = N'MSOLEDBSQL';

			EXEC sp_addlinkedsrvlogin  
				@rmtsrvname = @ServerIp,  
				@useself = 'false',  
				@rmtuser = @ServerSqlLogin,
				@rmtpassword = @ServerSqlPass;

			set @message='Linked Server '+@ServerIp+' is created... at' ;
			--raiserror( @message,16,1)
		end try
		begin catch
			set @message= 'Linked Server '+@ServerIp+' is already exist...';
			--print @message
			--raiserror( @message,16,1)
		end catch

		--Test connection
		declare  @retval int;
		begin try
			exec @retval = sys.sp_testlinkedserver @ServerIp;
		end try
		begin catch
			set @retval = sign(@@error);
		end catch;
	
		if @retval <> 0
				set @message= 'Unable to connect to '+@ServerIp+'. This operation will be tried later!'
		if @retval=0
			begin
				set @message='connect successful...'
				--print @message
			end
	end

	if(@Execute=1 and @message like'%successful%')
		begin
			declare @Query nvarchar(max)
			set @Query='insert into ltr1400  Select '''+@ServerIp+''' as ServerIp ,e.* From ['+
					@ServerIp+'].daftar.dbo.ltr1400 e Where Date_Im_Ex>='''+@DateFrom+
						''' And Date_Im_Ex <=''' +@DateUntil+''''+
						'  and SUBSTRING(cast(e.Kol_Mom as nvarchar),1,4) in (select SUBSTRING(s.xEdare,1,4) as Kol_Mom from Taj_Tb_Servers s where s.xServerIP='''+@ServerIp+''')'+

						 '  insert into Comison Select Com.* From ['+@ServerIp+'].daftar.dbo.Comison Com Inner '+
						 'Join  ['+@ServerIp+'].daftar.dbo.ltr1400  On Com_Andi=Andi and Com_Kol_Mom=Kol_Mom Where Date_Im_Ex>='''+@DateFrom+
						 ''' And Date_Im_Ex <='''+@DateUntil+''' And Com_Year=''1400'''+
						 '  and SUBSTRING(cast(Kol_Mom as nvarchar),1,4) in (select SUBSTRING(s.xEdare,1,4) as Kol_Mom from Taj_Tb_Servers s where s.xServerIP='''+@ServerIp+''')'+

						'	insert into Taghsit Select Tag.* From ['+@ServerIp+'].daftar.dbo.Taghsit Tag Inner Join ['+@ServerIp+'].daftar.dbo.ltr1400'+
						' On Tag_Andi=Andi and Tag_Kol_Mom=Kol_Mom Where Date_Im_Ex>='''+@DateFrom+''' And Date_Im_Ex <='''+@DateUntil+
						 '''  and SUBSTRING(cast(Kol_Mom as nvarchar),1,4) in (select SUBSTRING(s.xEdare,1,4) as Kol_Mom from Taj_Tb_Servers s where s.xServerIP='''+@ServerIp+''')'+
						' And Tag_Year=''1400'''

			--print @Query
			begin try
				exec(@Query);
				set @message='transaction has done successfully'
			end try
			begin catch
				set @message= ERROR_MESSAGE();
			end catch
		end

	--print @message

