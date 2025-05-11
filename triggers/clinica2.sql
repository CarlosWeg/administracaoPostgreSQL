-- Ao fechar um atendimento, atualizar o saldo devedor e preencher as parcelas (criar tabela).

SELECT *
  FROM atendimento;

SELECT *
  FROM parcela;

INSERT INTO atendimento
 VALUES (default,CURRENT_DATE,200,1,1,10)


CREATE OR REPLACE FUNCTION fn_gerar_parcelas_ao_fechar_atendimento()
RETURNS TRIGGER AS $$
DECLARE
	n_valor_parcela NUMERIC(10,2);
	n_valor_restante NUMERIC(10,2);
BEGIN

	IF NEW.parcelas <= 0 THEN
		RAISE NOTICE 'Não foram geradas pois o número de parcelas não é maior que zero: %',NEW.parcelas;
		RETURN NEW;
	ELSIF NEW.valor <= 0 THEN 
		RAISE NOTICE 'Não foram geradas pois o valor do atendimento não é maior que zero: %',NEW.valor;
		RETURN NEW;
	END IF;

	n_valor_parcela := TRUNC(NEW.valor / NEW.parcelas,2);
	n_valor_restante := NEW.valor - (n_valor_parcela * NEW.parcelas);

	FOR i IN 1..NEW.parcelas LOOP

		INSERT INTO parcela
		       (atendimento_sequencia,numero,vencimento,valor)
		VALUES (NEW.atendimento_sequencia,i,CURRENT_DATE + ((i-1) * INTERVAL '30 days'),
		        CASE WHEN i = NEW.parcelas THEN n_valor_parcela + n_valor_restante ELSE n_valor_parcela END);

	END LOOP;

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER tg_gerar_parcelas_ao_fechar_atendimento
AFTER INSERT OR UPDATE ON atendimento
FOR EACH ROW
EXECUTE FUNCTION fn_gerar_parcelas_ao_fechar_atendimento();

