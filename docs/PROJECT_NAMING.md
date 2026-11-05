# Nomes do projeto

- Nome apresentado: **Bicho a Bicho**.
- Pasta pretendida: `C:\Projetos\BichoABicho`.
- Pacote Dart, imports e executáveis de desktop: `bicho_a_bicho`.
- Produto macOS: `bicho_a_bicho.app`.

Os títulos, metadados de produto, imports dos testes e ferramentas usam o nome atual. O nome do APK produzido pelo Flutter continua sendo `app-debug.apk` ou `app-release.apk`, conforme o modo de compilação.

## Identificadores preservados

O Android mantém `com.example.animal_game` como applicationId e namespace; Apple mantém `com.example.animalGame` e seus IDs de testes. O Linux mantém o application ID existente. São identificadores técnicos persistentes, não nomes exibidos. As configurações Firebase e os comandos de DebugView continuam usando esses valores.

Mudar o applicationId ou bundle ID cria outra identidade de aplicativo para o sistema, não uma atualização do aplicativo instalado. Isso separaria os dados locais e exigiria registros/configurações correspondentes no Firebase e nas lojas. Não foram alterados os registros remotos, chaves de persistência, arquivos de credenciais nem o histórico Git. As ocorrências desses identificadores antigos são intencionais para compatibilidade.

Após mover a pasta, abrir `C:\Projetos\BichoABicho` no editor. Executar `flutter pub get` após a mudança regenera os caminhos locais das dependências. Os diretórios temporários de compilação são regenerados no novo caminho.

Nesta sessão, o Windows impediu a renomeação porque o próprio Codex/ChatGPT e processos auxiliares mantêm a pasta aberta. Nenhum desses processos foi encerrado à força. O projeto ainda está no caminho anterior. Foi preparado `C:\Projetos\Renomear-BichoABicho.ps1` para executar depois de fechar o projeto; ele verifica os caminhos, recusa destino existente e renomeia a pasta inteira, incluindo Git, sem copiar ou excluir arquivos.

Em um PowerShell aberto fora da pasta do projeto:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Projetos\Renomear-BichoABicho.ps1
```

O parâmetro de execução se aplica somente a esse processo. O script não modifica a política de execução do computador.
