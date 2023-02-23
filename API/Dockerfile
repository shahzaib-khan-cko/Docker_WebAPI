FROM mcr.microsoft.com/dotnet/sdk:7.0 as build-env
WORKDIR /API
COPY API/*.csproj .
RUN dotnet restore
COPY API .
RUN dotnet publish -c Release --os linux -o /publish

FROM mcr.microsoft.com/dotnet/aspnet:7.0 as runtime
WORKDIR /publish
COPY --from=build-env /publish .
EXPOSE 5000
ENTRYPOINT ["dotnet", "API.dll"]