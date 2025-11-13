import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { AgentsService } from "./agents.service";
import { CreateAgentDto } from "./dto/create-agent.dto";
import { UpdateAgentDto } from "./dto/update-agent.dto";
import { UpdateAgentStatusDto } from "./dto/update-agent-status.dto";
import { TenantGuard } from "../guards/tenant.guard";

@ApiTags("agents")
@Controller("agents")
@UseGuards(TenantGuard)
@ApiBearerAuth()
export class AgentsController {
  constructor(private readonly agentsService: AgentsService) {}

  @Post()
  @ApiOperation({ summary: "Create a new agent" })
  @ApiResponse({ status: 201, description: "Agent created successfully" })
  @ApiResponse({ status: 400, description: "Bad request - validation failed" })
  @ApiResponse({
    status: 409,
    description: "Conflict - agent name already exists",
  })
  create(@Body() createAgentDto: CreateAgentDto) {
    return this.agentsService.create(createAgentDto);
  }

  @Get()
  @ApiOperation({ summary: "Get all agents for the tenant" })
  @ApiResponse({
    status: 200,
    description: "Returns all agents for the tenant",
  })
  findAll(@Req() req: any) {
    const tenantId = req.tenant.id;
    return this.agentsService.findAll(tenantId);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get a single agent by ID" })
  @ApiResponse({ status: 200, description: "Returns the agent" })
  @ApiResponse({ status: 404, description: "Agent not found" })
  findOne(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.agentsService.findOne(id, tenantId);
  }

  @Patch(":id")
  @ApiOperation({ summary: "Update an agent" })
  @ApiResponse({ status: 200, description: "Agent updated successfully" })
  @ApiResponse({ status: 404, description: "Agent not found" })
  @ApiResponse({
    status: 409,
    description: "Conflict - agent name already exists",
  })
  update(
    @Param("id") id: string,
    @Body() updateAgentDto: UpdateAgentDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.agentsService.update(id, tenantId, updateAgentDto);
  }

  @Patch(":id/status")
  @ApiOperation({ summary: "Update agent status" })
  @ApiResponse({
    status: 200,
    description: "Agent status updated successfully",
  })
  @ApiResponse({ status: 404, description: "Agent not found" })
  updateStatus(
    @Param("id") id: string,
    @Body() updateAgentStatusDto: UpdateAgentStatusDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.agentsService.updateStatus(
      id,
      tenantId,
      updateAgentStatusDto.status as "DRAFT" | "PUBLISHED" | "DISABLED"
    );
  }

  @Delete(":id")
  @ApiOperation({ summary: "Delete an agent" })
  @ApiResponse({ status: 200, description: "Agent deleted successfully" })
  @ApiResponse({ status: 404, description: "Agent not found" })
  @ApiResponse({
    status: 409,
    description: "Cannot delete agent with conversations",
  })
  remove(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.agentsService.remove(id, tenantId);
  }
}
