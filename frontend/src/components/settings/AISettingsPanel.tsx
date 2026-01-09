/**
 * AISettingsPanel Component
 *
 * Settings panel for configuring AI providers, API keys, and viewing usage statistics.
 * Supports Gemini, OpenAI, and custom OpenAI-compatible providers.
 */

import { useState, useEffect } from "react";
import {
  Cpu,
  Key,
  Server,
  TestTube2,
  RefreshCw,
  Check,
  X,
  Loader2,
  Eye,
  EyeOff,
  BarChart3,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/components/ui/use-toast";
import {
  getAISettings,
  updateAISettings,
  testProviderConfig,
  resetProviderConfig,
  type ProviderConfigDisplay,
  type UsageStats,
} from "@/api/ai";

// ============================================================================
// TYPES
// ============================================================================

interface ProviderConfig {
  api_url: string;
  api_key: string;
  model: string;
  vision_model: string;
  image_gen_model: string;
  embedding_model: string;
}

interface TestResult {
  success: boolean;
  message: string;
  model?: string;
}

// ============================================================================
// CONSTANTS
// ============================================================================

const PROVIDERS = [
  {
    id: "gemini",
    name: "Google Gemini",
    description: "Google AI Studio - Gemini models",
    defaultUrl: "https://generativelanguage.googleapis.com/v1beta",
    models: {
      chat: ["gemini-3-flash-preview", "gemini-3-pro-preview"],
      vision: ["gemini-3-flash-preview", "gemini-3-pro-preview"],
      image_gen: ["gemini-3-pro-image-preview", "gemini-3-flash-preview"],
      embedding: ["gemini-embedding-001", "text-embedding-004"],
    },
  },
  {
    id: "openai",
    name: "OpenAI",
    description: "OpenAI API - GPT and DALL-E models",
    defaultUrl: "https://api.openai.com/v1",
    models: {
      chat: ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo"],
      vision: ["gpt-4o", "gpt-4o-mini"],
      image_gen: ["dall-e-3", "dall-e-2"],
      embedding: ["text-embedding-3-small", "text-embedding-3-large", "text-embedding-ada-002"],
    },
  },
  {
    id: "custom",
    name: "Custom Provider",
    description: "OpenAI-compatible API endpoint (local proxy, etc.)",
    defaultUrl: "http://localhost:8317/v1",
    models: {
      chat: [],
      vision: [],
      image_gen: [],
      embedding: [],
    },
  },
];

const PROVIDER_SHORT_LABELS: Record<string, string> = {
  gemini: "Gemini",
  openai: "OpenAI",
  custom: "Custom",
};

// ============================================================================
// COMPONENT
// ============================================================================

export function AISettingsPanel() {
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [testingProvider, setTestingProvider] = useState<string | null>(null);
  const [testResults, setTestResults] = useState<Record<string, TestResult>>(
    {},
  );

  const [defaultProvider, setDefaultProvider] = useState("gemini");
  const [providerConfigs, setProviderConfigs] = useState<
    Record<string, ProviderConfig>
  >({});
  const [displayConfigs, setDisplayConfigs] = useState<
    Record<string, ProviderConfigDisplay>
  >({});
  const [usage, setUsage] = useState<UsageStats | null>(null);

  const [showApiKeys, setShowApiKeys] = useState<Record<string, boolean>>({});

  const { toast } = useToast();

  // ============================================================================
  // DATA LOADING
  // ============================================================================

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    setIsLoading(true);
    try {
      const settings = await getAISettings();
      setDefaultProvider(settings.default_provider);
      setDisplayConfigs(settings.provider_configs);
      setUsage(settings.usage || null);

      // Initialize provider configs from display configs
      const configs: Record<string, ProviderConfig> = {};
      for (const provider of PROVIDERS) {
        const display = settings.provider_configs[provider.id];
        configs[provider.id] = {
          api_url: display?.api_url || provider.defaultUrl,
          api_key: "", // Don't populate - will be masked
          model: display?.model || "",
          vision_model: display?.vision_model || "",
          image_gen_model: display?.image_gen_model || "",
          embedding_model: display?.embedding_model || "",
        };
      }
      setProviderConfigs(configs);
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to load AI settings",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  // ============================================================================
  // ACTIONS
  // ============================================================================

  const handleSave = async () => {
    setIsSaving(true);
    try {
      // Only send configs that have been modified (have api_key set)
      const configsToSave: Record<string, Partial<ProviderConfig>> = {};
      for (const [provider, config] of Object.entries(providerConfigs)) {
        const updates: Partial<ProviderConfig> = {};
        if (config.api_url) updates.api_url = config.api_url;
        if (config.api_key) updates.api_key = config.api_key;
        if (config.model) updates.model = config.model;
        if (config.vision_model) updates.vision_model = config.vision_model;
        if (config.image_gen_model)
          updates.image_gen_model = config.image_gen_model;
        if (config.embedding_model)
          updates.embedding_model = config.embedding_model;

        if (Object.keys(updates).length > 0) {
          configsToSave[provider] = updates;
        }
      }

      await updateAISettings({
        default_provider: defaultProvider,
        provider_configs: configsToSave,
      });

      toast({
        title: "Settings saved",
        description: "Your AI provider settings have been updated",
      });

      // Reload settings to get updated display
      await loadSettings();
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to save settings",
        variant: "destructive",
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleTestProvider = async (providerId: string) => {
    const config = providerConfigs[providerId];
    if (!config.api_url) {
      toast({
        title: "Missing API URL",
        description: "Please enter an API URL to test",
        variant: "destructive",
      });
      return;
    }

    // Use stored key if new one not provided
    const apiKey =
      config.api_key ||
      (displayConfigs[providerId]?.api_key_set ? "stored" : "");
    if (!apiKey && providerId !== "custom") {
      toast({
        title: "Missing API Key",
        description: "Please enter an API key to test",
        variant: "destructive",
      });
      return;
    }

    setTestingProvider(providerId);
    setTestResults((prev) => ({ ...prev, [providerId]: undefined as any }));

    try {
      const result = await testProviderConfig(
        config.api_url,
        config.api_key || "stored", // Backend will use stored key if 'stored'
        config.model || "default",
      );

      setTestResults((prev) => ({
        ...prev,
        [providerId]: {
          success: result.success,
          message: result.message,
          model: result.model,
        },
      }));

      toast({
        title: result.success ? "Connection successful" : "Connection failed",
        description: result.message,
        variant: result.success ? "default" : "destructive",
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Test failed";
      setTestResults((prev) => ({
        ...prev,
        [providerId]: { success: false, message },
      }));
      toast({
        title: "Test failed",
        description: message,
        variant: "destructive",
      });
    } finally {
      setTestingProvider(null);
    }
  };

  const handleResetProvider = async (providerId: string) => {
    try {
      await resetProviderConfig(providerId);
      toast({
        title: "Provider reset",
        description: `${providerId} configuration has been reset to defaults`,
      });
      await loadSettings();
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to reset provider",
        variant: "destructive",
      });
    }
  };

  const updateProviderConfig = (
    providerId: string,
    field: keyof ProviderConfig,
    value: string,
  ) => {
    setProviderConfigs((prev) => ({
      ...prev,
      [providerId]: {
        ...prev[providerId],
        [field]: value,
      },
    }));
  };

  // ============================================================================
  // RENDER
  // ============================================================================

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Default Provider Selection */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <Cpu className="h-5 w-5 text-indigo-500" />
            Default AI Provider
          </CardTitle>
          <CardDescription>
            Choose which AI provider to use for image analysis and generation
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <Select value={defaultProvider} onValueChange={setDefaultProvider}>
            <SelectTrigger className="w-full md:max-w-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {PROVIDERS.map((provider) => (
                <SelectItem key={provider.id} value={provider.id}>
                  <div className="flex items-center gap-2">
                    {provider.name}
                    {displayConfigs[provider.id]?.api_key_set && (
                      <Badge variant="secondary" className="ml-2 text-xs">
                        Configured
                      </Badge>
                    )}
                  </div>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Provider Configuration Tabs */}
      <Card>
        <CardHeader className="px-4 py-4 md:px-6 md:py-6">
          <CardTitle className="flex items-center gap-2">
            <Key className="h-5 w-5 text-indigo-500" />
            Provider Configuration
          </CardTitle>
          <CardDescription>
            Configure API keys and endpoints for each provider
          </CardDescription>
        </CardHeader>
        <CardContent className="px-4 pb-4 md:px-6 md:pb-6">
          <Tabs defaultValue="gemini" className="w-full">
            <TabsList className="flex w-full gap-2 justify-start overflow-x-auto scrollbar-hide touch-pan-x overscroll-x-contain">
              {PROVIDERS.map((provider) => (
                <TabsTrigger
                  key={provider.id}
                  value={provider.id}
                  className="min-w-[120px] flex-1 px-2 text-xs sm:min-w-0 sm:px-3 sm:text-sm"
                >
                  <span className="sm:hidden">
                    {PROVIDER_SHORT_LABELS[provider.id] || provider.name}
                  </span>
                  <span className="hidden sm:inline">{provider.name}</span>
                </TabsTrigger>
              ))}
            </TabsList>

            {PROVIDERS.map((provider) => (
              <TabsContent
                key={provider.id}
                value={provider.id}
                className="space-y-4 pt-4"
              >
                <div className="text-sm text-gray-600 dark:text-gray-400 mb-4">
                  {provider.description}
                </div>

                {/* API URL */}
                <div className="space-y-2">
                  <Label htmlFor={`${provider.id}-url`}>
                    <Server className="h-4 w-4 inline mr-2" />
                    API URL
                  </Label>
                  <Input
                    id={`${provider.id}-url`}
                    value={providerConfigs[provider.id]?.api_url || ""}
                    onChange={(e) =>
                      updateProviderConfig(
                        provider.id,
                        "api_url",
                        e.target.value,
                      )
                    }
                    placeholder={provider.defaultUrl}
                  />
                </div>

                {/* API Key */}
                <div className="space-y-2">
                  <Label htmlFor={`${provider.id}-key`}>
                    <Key className="h-4 w-4 inline mr-2" />
                    API Key
                    {displayConfigs[provider.id]?.api_key_set && (
                      <Badge variant="secondary" className="ml-2 text-xs">
                        Stored
                      </Badge>
                    )}
                  </Label>
                  <div className="flex gap-2">
                    <div className="relative flex-1">
                      <Input
                        id={`${provider.id}-key`}
                        type={showApiKeys[provider.id] ? "text" : "password"}
                        value={providerConfigs[provider.id]?.api_key || ""}
                        onChange={(e) =>
                          updateProviderConfig(
                            provider.id,
                            "api_key",
                            e.target.value,
                          )
                        }
                        placeholder={
                          displayConfigs[provider.id]?.api_key_set
                            ? "Enter new key to replace stored key"
                            : "Enter your API key"
                        }
                      />
                      <button
                        type="button"
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300"
                        onClick={() =>
                          setShowApiKeys((prev) => ({
                            ...prev,
                            [provider.id]: !prev[provider.id],
                          }))
                        }
                      >
                        {showApiKeys[provider.id] ? (
                          <EyeOff className="h-4 w-4" />
                        ) : (
                          <Eye className="h-4 w-4" />
                        )}
                      </button>
                    </div>
                  </div>
                </div>

                {/* Model Selection (for custom provider or override) */}
                {provider.id === "custom" ? (
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor={`${provider.id}-model`}>
                        Chat/Vision Model
                      </Label>
                      <Input
                        id={`${provider.id}-model`}
                        value={providerConfigs[provider.id]?.model || ""}
                        onChange={(e) =>
                          updateProviderConfig(
                            provider.id,
                            "model",
                            e.target.value,
                          )
                        }
                        placeholder="e.g., gpt-4o, claude-3-opus"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor={`${provider.id}-image-model`}>
                        Image Generation Model
                      </Label>
                      <Input
                        id={`${provider.id}-image-model`}
                        value={
                          providerConfigs[provider.id]?.image_gen_model || ""
                        }
                        onChange={(e) =>
                          updateProviderConfig(
                            provider.id,
                            "image_gen_model",
                            e.target.value,
                          )
                        }
                        placeholder="e.g., dall-e-3, sdxl"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor={`${provider.id}-embedding-model`}>
                        Embedding Model
                      </Label>
                      <Input
                        id={`${provider.id}-embedding-model`}
                        value={
                          providerConfigs[provider.id]?.embedding_model || ""
                        }
                        onChange={(e) =>
                          updateProviderConfig(
                            provider.id,
                            "embedding_model",
                            e.target.value,
                          )
                        }
                        placeholder="e.g., text-embedding-3-small"
                      />
                    </div>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {provider.models.chat.length > 0 && (
                      <div className="space-y-2">
                        <Label>Chat Model (Optional Override)</Label>
                        <Select
                          value={providerConfigs[provider.id]?.model || "default"}
                          onValueChange={(value) =>
                            updateProviderConfig(provider.id, "model", value === "default" ? "" : value)
                          }
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Use default model" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="default">Use default</SelectItem>
                            {provider.models.chat.map((model) => (
                              <SelectItem key={model} value={model}>
                                {model}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                    )}
                    {provider.models.embedding.length > 0 && (
                      <div className="space-y-2">
                        <Label>Embedding Model</Label>
                        <Select
                          value={providerConfigs[provider.id]?.embedding_model || "default"}
                          onValueChange={(value) =>
                            updateProviderConfig(provider.id, "embedding_model", value === "default" ? "" : value)
                          }
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Use default model" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="default">Use default</SelectItem>
                            {provider.models.embedding.map((model) => (
                              <SelectItem key={model} value={model}>
                                {model}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          Used for duplicate detection and similarity search
                        </p>
                      </div>
                    )}
                  </div>
                )}

                {/* Test Result */}
                {testResults[provider.id] && (
                  <div
                    className={`p-3 rounded-lg flex items-start gap-2 ${
                      testResults[provider.id].success
                        ? "bg-green-50 dark:bg-green-900/30 text-green-800 dark:text-green-300"
                        : "bg-red-50 dark:bg-red-900/30 text-red-800 dark:text-red-300"
                    }`}
                  >
                    {testResults[provider.id].success ? (
                      <Check className="h-5 w-5 shrink-0" />
                    ) : (
                      <X className="h-5 w-5 shrink-0" />
                    )}
                    <div>
                      <p className="font-medium">
                        {testResults[provider.id].message}
                      </p>
                      {testResults[provider.id].model && (
                        <p className="text-sm mt-1">
                          Model: {testResults[provider.id].model}
                        </p>
                      )}
                    </div>
                  </div>
                )}

                {/* Actions */}
                <div className="flex flex-col gap-2 pt-4 border-t dark:border-gray-700 sm:flex-row">
                  <Button
                    variant="outline"
                    onClick={() => handleTestProvider(provider.id)}
                    disabled={testingProvider === provider.id}
                    className="w-full sm:w-auto"
                  >
                    {testingProvider === provider.id ? (
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    ) : (
                      <TestTube2 className="h-4 w-4 mr-2" />
                    )}
                    Test Connection
                  </Button>
                  <Button
                    variant="ghost"
                    onClick={() => handleResetProvider(provider.id)}
                    className="w-full sm:w-auto"
                  >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Reset to Defaults
                  </Button>
                </div>
              </TabsContent>
            ))}
          </Tabs>
        </CardContent>
      </Card>

      {/* Usage Statistics */}
      {usage && (
        <Card>
          <CardHeader className="px-4 py-4 md:px-6 md:py-6">
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5 text-indigo-500" />
              Usage Statistics
            </CardTitle>
            <CardDescription>Your AI usage and rate limits</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6 px-4 pb-4 md:px-6 md:pb-6">
            {/* Extractions */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label>Item Extractions (Today)</Label>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {usage.daily.extractions} / {usage.limits.daily_extractions}
                </span>
              </div>
              <Progress
                value={
                  (usage.daily.extractions / usage.limits.daily_extractions) *
                  100
                }
                className="h-2"
              />
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {usage.remaining.extractions} remaining today
              </p>
            </div>

            {/* Generations */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label>Image Generations (Today)</Label>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {usage.daily.generations} / {usage.limits.daily_generations}
                </span>
              </div>
              <Progress
                value={
                  (usage.daily.generations / usage.limits.daily_generations) *
                  100
                }
                className="h-2"
              />
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {usage.remaining.generations} remaining today
              </p>
            </div>

            {/* Embeddings */}
            {usage.limits.daily_embeddings > 0 && (
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label>Embeddings (Today)</Label>
                  <span className="text-sm text-gray-500 dark:text-gray-400">
                    {usage.daily.embeddings} / {usage.limits.daily_embeddings}
                  </span>
                </div>
                <Progress
                  value={
                    (usage.daily.embeddings / usage.limits.daily_embeddings) *
                    100
                  }
                  className="h-2"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {usage.remaining.embeddings} remaining today
                </p>
              </div>
            )}

            {/* Total Usage */}
            <div className="pt-4 border-t dark:border-gray-700">
              <p className="text-sm text-gray-600 dark:text-gray-400">
                <span className="font-medium text-gray-900 dark:text-white">Total Usage:</span>{" "}
                {usage.total.extractions} extractions, {usage.total.generations}{" "}
                generations{usage.total.embeddings > 0 && `, ${usage.total.embeddings} embeddings`}
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Save Button */}
      <div className="flex">
        <Button
          onClick={handleSave}
          disabled={isSaving}
          size="lg"
          className="w-full sm:w-auto sm:ml-auto"
        >
          {isSaving ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Saving...
            </>
          ) : (
            "Save Settings"
          )}
        </Button>
      </div>
    </div>
  );
}

export default AISettingsPanel;
