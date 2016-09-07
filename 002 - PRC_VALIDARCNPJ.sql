use Toolbox
go

If Exists (Select 1 From sysobjects Where name = 'PRC_VALIDARCNPJ')
	Drop Procedure PRC_VALIDARCNPJ
go

CREATE PROCEDURE dbo.PRC_VALIDARCNPJ @p_CNPJ VarChar(18), @p_retorno Bit Output, @p_mensagem VarChar(100) Output
AS
SET NOCOUNT ON
/*
Fórmula para validação de CNPJ no formato ab.cde.fgh/0001-xy

Parâmetros:
    @p_CNPJ      = CNPJ no formatado ou não, obrigatório os dois dígitos de controle
    @p_retorno  = 0 -> Inválido ou 1 -> Válido
    @p_mensagem = Complemento ao parâmetro @p_retorno

Exemplo:
    Declare @retorno bit, @mensagem VarChar(100)
    exec PRC_VALIDARCNPJ @p_CNPJ = '18.781.203/0001-28', @p_retorno = @retorno Output, @p_mensagem = @mensagem Output
--    exec PRC_VALIDARCNPJ @p_CNPJ = '11.222.333/0001-81', @p_retorno = @retorno Output, @p_mensagem = @mensagem Output
    Select @retorno Retorno, @mensagem Mensagem
*/

Begin
    Declare @a int,
            @b int,
            @c int,
            @d int,
            @e int,
            @f int,
            @g int,
            @h int,
            @i int,
            @j int,
            @k int,
            @l int,
            @x int,
            @y int,
            @ctrl1 int,
            @ctrl2 int,
            @CNPJ varchar(18)

    --Zera variaveis de retorno
    Select @p_retorno = 0, @p_mensagem = ''

    --Formata o CNPJ recebido
    Select @CNPJ = @p_CNPJ
    Select @CNPJ = REPLACE(@CNPJ,'.','')
    Select @CNPJ = REPLACE(@CNPJ,'-','')
    Select @CNPJ = REPLACE(@CNPJ,'/','')
	

    If left(@CNPJ,9) in ('000000000', '111111111', '222222222', '333333333', '444444444',
                        '555555555', '666666666', '777777777', '888888888', '999999999')
        or ltrim(rtrim(isnull(@CNPJ,''))) = ''
        Begin
            Select @p_retorno = 0, @p_mensagem = 'CNPJ Inválido.'
            Return
        End

    --Separa as posicoes antes do calculo dos digitos de controle
    Select @a = left(@CNPJ, 1)
    Select @b = substring(@CNPJ, 2,  1)
    Select @c = substring(@CNPJ, 3,  1)
    Select @d = substring(@CNPJ, 4,  1)
    Select @e = substring(@CNPJ, 5,  1)
    Select @f = substring(@CNPJ, 6,  1)
    Select @g = substring(@CNPJ, 7,  1)
    Select @h = substring(@CNPJ, 8,  1)
    Select @i = substring(@CNPJ, 9,  1)
    Select @j = substring(@CNPJ, 10, 1)
    Select @k = substring(@CNPJ, 11, 1)
    Select @l = substring(@CNPJ, 12, 1)
    Select @x = substring(@CNPJ, 13, 1)
    Select @y = substring(@CNPJ, 14, 1)

    --Calculo do primeiro digito de controle (x)
    Select @ctrl1 = (@a * 5 + @b * 4 + @c * 3 + @d * 2 + @e * 9 + @f * 8 + @g * 7 + @h * 6 + @i * 5 + @j * 4 + @k * 3 + @l * 2 )
    Select @ctrl1 = @ctrl1 % 11
    If @ctrl1 < 2
        Select @ctrl1 = 0
    Else
        Select @ctrl1 = 11 - @ctrl1

    If @x <> @ctrl1
        Begin
            Select @p_retorno = 0, @p_mensagem = 'Primeiro digito não confere.'
            Return
        End
    
    --Calculo do segundo digito de controle (y)
    Select @ctrl2 = (@a * 6 + @b * 5 + @c * 4 + @d * 3 + @e * 2 + @f * 9 + @g * 8 + @h * 7 + @i * 6 + @j * 5 + @k * 4 + @l * 3 + @ctrl1 * 2 )
    Select @ctrl2 = @ctrl2 % 11
    If @ctrl2 < 2
        Select @ctrl2 = 0
    Else
        Select @ctrl2 = 11 - @ctrl2

    If @y <> @ctrl2
        Begin
            Select @p_retorno = 0, @p_mensagem = 'Segundo digito não confere.'
            Return
        End


    Select @p_retorno = 1, @p_mensagem = 'CNPJ Válido.'
    Return    
end
