import 'dotenv/config';
import fastify from 'fastify';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';

const app = fastify({ logger: true });
const PORT = Number(process.env.PORT) || 3000;

app.register(swagger, {
  openapi: {
    info: {
      title: 'MesclaInvest API',
      description: 'Documentação das rotas com Fastify',
      version: '1.0.0'
    }
  }
});

app.register(swaggerUi, {
  routePrefix: '/docs'
});

// Exemplo de rota
app.get('/', {
  schema: {
    summary: 'Health check da API',
    response: {
      200: {
        type: 'object',
        properties: {
          hello: { type: 'string' }
        }
      }
    }
  }
}, async () => {
  return { hello: 'world - backend ativo!' };
});

const start = async () => {
  try {
    await app.listen({ port: PORT });
    console.log(`Servidor rodando em http://localhost:${PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();