-- Atualizar o valor do atendimento ao incluir vacinação;

CREATE OR REPLACE FUNCTION fn_atualizar_valor_atendimento_vacina()
RETURNS TRIGGER AS $$
DECLARE
	valor_vacina NUMERIC(10,2);
BEGIN


	SELECT valor
	  INTO valor_vacina
	  FROM vacina
	 WHERE vacina_codigo = NEW.vacina_codigo;

	IF valor_vacina IS NULL THEN
		RAISE NOTICE 'Vacina com código % possui o valor nulo ou não foi encontrada.',NEW.vacina_codigo;
		RETURN NEW;
	END IF;

	UPDATE atendimento
	   SET valor = COALESCE(valor,0) + valor_vacina
	 WHERE atendimento_sequencia = NEW.atendimento_sequencia;

	RETURN NEW;

END;
$$LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER tg_atualizar_valor_atendimento_vacina
AFTER INSERT ON atendimento_vacina
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_valor_atendimento_vacina();