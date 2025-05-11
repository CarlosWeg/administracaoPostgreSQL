-- Atualizar o valor do atendimento ao incluir produtos e serviços;

CREATE OR REPLACE FUNCTION fn_atualiza_valor_atendimento_produto_servico()
RETURNS TRIGGER AS $$
DECLARE
	valor_adicionar NUMERIC(10,2);
BEGIN

	IF TG_TABLE_NAME = 'atendimento_servico' THEN
	
		SELECT valor
		  INTO valor_adicionar
		  FROM servico
		 WHERE servico_codigo = NEW.servico_codigo;

		IF NOT FOUND THEN
			RAISE EXCEPTION 'Produto % não encontrado!',NEW.produto_codigo;
		END IF;
		 
	ELSEIF TG_TABLE_NAME = 'atendimento_produto' THEN
	
		SELECT valor
		  INTO valor_adicionar
		  FROM produto
		 WHERE produto_codigo = NEW.produto_codigo;

		IF NOT FOUND THEN
			RAISE EXCEPTION 'Produto % não encontrado!',NEW.produto_codigo;
		END IF;
		 
	END IF;

	IF COALESCE(valor_adicionar,0) <= 0 THEN
		RAISE NOTICE 'O valor do produto ou serviço é menor ou igual a zero! Tabela: % | Código: %',TG_TABLE_NAME,valor_adicionar;
		RETURN NEW;
	ELSIF COALESCE(NEW.quantidade,0) <= 0 THEN
		RAISE NOTICE 'A quantidade é menor ou igual a zero! Tabela: % | Código: %',TG_TABLE_NAME,valor_adicionar;
		RETURN NEW;
	END IF;

	UPDATE atendimento
	   SET valor = valor + (valor_adicionar * NEW.quantidade)
	 WHERE atendimento_sequencia = NEW.atendimento_sequencia;

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_atualiza_valor_atendimento_produto
AFTER INSERT ON atendimento_produto
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_valor_atendimento_produto_servico();

CREATE OR REPLACE TRIGGER tg_atualiza_valor_atendimento_servico
AFTER INSERT ON atendimento_servico
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_valor_atendimento_produto_servico();