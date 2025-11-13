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
  ApiSecurity,
} from "@nestjs/swagger";
import { ToolsService } from "./tools.service";
import { CreateToolDto } from "./dto/create-tool.dto";
import { UpdateToolDto } from "./dto/update-tool.dto";
import { TenantGuard } from "../guards/tenant.guard";

@ApiTags("tools")
@Controller("tools")
@UseGuards(TenantGuard)
@ApiSecurity("X-Tenant-Id")
export class ToolsController {
  constructor(private readonly toolsService: ToolsService) {}

  @Post()
  @ApiOperation({ summary: "Register a new tool" })
  @ApiResponse({ status: 201, description: "Tool created successfully" })
  @ApiResponse({ status: 400, description: "Bad request - validation failed" })
  @ApiResponse({
    status: 409,
    description: "Tool with this name already exists",
  })
  create(@Body() createToolDto: CreateToolDto, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.toolsService.create(createToolDto, tenantId);
  }

  @Get()
  @ApiOperation({ summary: "List all tools for tenant" })
  @ApiResponse({ status: 200, description: "Tools retrieved successfully" })
  findAll(@Req() req: any) {
    const tenantId = req.tenant.id;
    return this.toolsService.findAll(tenantId);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get tool by ID" })
  @ApiResponse({ status: 200, description: "Tool retrieved successfully" })
  @ApiResponse({ status: 404, description: "Tool not found" })
  findOne(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.toolsService.findOne(id, tenantId);
  }

  @Patch(":id")
  @ApiOperation({ summary: "Update tool configuration" })
  @ApiResponse({ status: 200, description: "Tool updated successfully" })
  @ApiResponse({ status: 404, description: "Tool not found" })
  @ApiResponse({ status: 409, description: "Tool name conflict" })
  update(
    @Param("id") id: string,
    @Body() updateToolDto: UpdateToolDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.toolsService.update(id, tenantId, updateToolDto);
  }

  @Delete(":id")
  @ApiOperation({ summary: "Delete tool" })
  @ApiResponse({ status: 200, description: "Tool deleted successfully" })
  @ApiResponse({ status: 404, description: "Tool not found" })
  remove(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.toolsService.remove(id, tenantId);
  }

  @Post(":id/test")
  @ApiOperation({
    summary: "Test tool execution",
    description:
      "Send test input to tool and get response (Phase 9: Will call actual MCP service)",
  })
  @ApiResponse({ status: 200, description: "Tool test executed" })
  @ApiResponse({ status: 404, description: "Tool not found" })
  testTool(@Param("id") id: string, @Body() testInput: any, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.toolsService.testTool(id, tenantId, testInput);
  }
}
