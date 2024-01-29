# Use the official .NET SDK as a build image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MachineDetailsAPI/MachineDetailsAPI.csproj", "MachineDetailsAPI/"]
RUN dotnet restore "./MachineDetailsAPI/./MachineDetailsAPI.csproj"
COPY . .
WORKDIR "/src/MachineDetailsAPI"
RUN dotnet build "./MachineDetailsAPI.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Use the official IIS image as the base image for the runtime environment
FROM mcr.microsoft.com/windows/servercore/iis AS runtime
WORKDIR /inetpub/wwwroot
COPY --from=build /app/build .

# Expose the necessary ports
EXPOSE 80

# Start IIS
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
